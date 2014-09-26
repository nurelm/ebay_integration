require 'json'

class Product
  def initialize(wombat_product, config={})
    @wombat_product = wombat_product["product"]
    @config = config
    @ebay_product = {}
  end

  def search_params
    { start_time_from: @config["ebay_start_time_from"], start_time_to: @config["ebay_start_time_to"], end_time_from: TIme.now.to_s, end_time_to: (Time.now + 30*24*60*60), include_variations: 'true', detail_level: 'ReturnAll', pagination: { entries_per_page: 25, page_number: @config['ebay_page_number'] } }
  end

  def ebay_product
    @ebay_product = ebay_product_initial_values(@config, @wombat_product)
    @ebay_product[:PrimaryCategory] = ebay_product_primary_category(@config) if @config["category_id"]
    @ebay_product[:ReturnPolicy] = ebay_product_return_policy(@config) if @config["return_policy"]
    @ebay_product[:ShippingDetails] = ebay_product_shipping_details(@config) if ebay_product_shipping_details_present?(@config)
    @ebay_product[:PaymentMethods] = ebay_product_payment_methods(@config) if @config["payment_methods"]
    @ebay_product[:PictureDetails] = ebay_product_picture_details(@wombat_product) if @wombat_product["images"].is_a?(Array)
    @ebay_product[:ItemSpecifics] = ebay_product_item_specifics(@wombat_product) if @wombat_product["properties"]

    if ebay_product_variants_present?(@wombat_product)
      @ebay_product[:Variations] = ebay_product_variantions_set(@wombat_product)
    else
      @ebay_product[:Quantity] = @wombat_product["quantity"]
      @ebay_product[:StartPrice] = @wombat_product["price"]
    end

    @ebay_product[:listing_details] = ebay_product_listing_details(@wombat_product)

    { item: @ebay_product }
  end

  def self.wombat_product_hash(ebay_product)
    wombat_product = wombat_product_initial_values(ebay_product)
    wombat_product[:images] = wombat_product_images(ebay_product) if ebay_product[:picture_details][:picture_url]

    if wombat_variants_present?(ebay_product)
      wombat_product[:variants] = wombat_variants(ebay_product)
    else
      wombat_product[:quantity] = ebay_product[:quantity]
      wombat_product[:start_price] = ebay_product[:price]
    end

    wombat_product
  end

  private
    def self.wombat_product_id(ebay_product)
      ebay_product[:application_data] || ebay_product[:item_id]
    end

    def self.wombat_product_initial_values(ebay_product)
      wombat_product = {}

      wombat_product["id"] = wombat_product_id(ebay_product)

      { "ebay_item_id" => :item_id, "name" => :title, "sku" => :sku, "description" => :description }.each do |wombat_key, ebay_value|
        wombat_product[wombat_key] = ebay_product[ebay_value]
      end

      wombat_product
    end

    def self.wombat_product_images(ebay_product)
      [ebay_product[:picture_details][:picture_url]].flatten.map { |picture_url| { url: picture_url } }
    end

    def self.wombat_variants(ebay_product)
      [ebay_product[:variations][:variation]].flatten.map { |variation| wombat_variant(variation) }
    end

    def self.wombat_variants_present?(ebay_product)
      ebay_product[:variations] && ebay_product[:variations][:variation] && !ebay_product[:variations][:variation].empty?
    end

    def self.wombat_variant(variation)
      wombat_variant = {}

      { sku: :sku, start_price: :price, quantity: :quantity }.each do |wombat_key, ebay_value|
        wombat_variant[wombat_key] = variation[ebay_value]
      end

      wombat_variant[:options] = {}

      variation[:variation_specifics][:name_value_list].each do |name_value|
        wombat_variant[:options].merge({ name_value[:name] => name_value[:value] })
      end

      wombat_variant
    end

    def ebay_product_initial_values(config, wombat_product)
      ebay_product = {}
      { "country" => :Country, "currency" => :Currency, "listing_duration" => :ListingDuration, "location" => :Location, "dispatch_time_max" => :DispatchTimeMax, "paypal_email_address" => :PayPalEmailAddress, "condition_id" => :ConditionID }.each do |womabt_key, ebay_value|
        ebay_product[ebay_value] = config[womabt_key] if config[womabt_key]
      end

      ebay_product[:ItemID] = wombat_product["ebay_item_id"] if wombat_product["ebay_item_id"]
      ebay_product[:ApplicationData] = wombat_product["id"]

      { "name" => :Title, "sku" => :SKU, "description" => :Description }.each do |wombat_key, ebay_value|
        ebay_product[ebay_value] = wombat_product[wombat_key]
      end

      ebay_product
    end

    def ebay_product_primary_category(config)
      { CategoryID: config["category_id"] }
    end

    def ebay_product_return_policy(config)
      JSON.parse(config["return_policy"])
    end

    def ebay_product_shipping_details(config)
      shipping_details = {}
      shipping_details[:ShippingType] = config["shipping_type"] if config["shipping_type"]
      shipping_details[:ShippingServiceOptions] = JSON.parse(config["shipping_service_options"]) if config["shipping_service_options"]
      shipping_details
    end

    def ebay_product_shipping_details_present?(config)
      config["shipping_service_options"] || config["shipping_type"]
    end

    def ebay_product_payment_methods(config)
      config["payment_methods"].split(',').map(&:strip)
    end

    def ebay_product_picture_details(wombat_product)
      { :PictureURL => wombat_product["images"].map { |image| image["url"].split('&').first } }
    end

    def ebay_product_item_specifics(wombat_product)
      { :NameValueList => wombat_product["properties"].map { |name, value| { Name: name, Value: value } } }
    end

    def ebay_product_variants_present?(wombat_product)
      wombat_product["variants"].is_a?(Array) && wombat_product["variants"].first
    end

    def ebay_product_variants(wombat_product)
      wombat_product["variants"].map { |variant| ebay_product_variant(variant) }
    end

    def ebay_product_variant(variant)
      ebay_variant = {}
      { "price" => :StartPrice, "quantity" => :Quantity, "sku" => :SKU }.each do |wombat_key, ebay_value|
        ebay_variant[ebay_value] = variant[wombat_key]
      end

      ebay_variant[:Deleted] = true if variant["deleted_at"].is_a?(String) && !variant["deleted_at"].strip.empty?

      ebay_variant[:VariationSpecifics] = {}
      ebay_variant[:VariationSpecifics][:NameValueList] = variant["options"].map { |name, value| { Name: name, Value: value } }

      ebay_variant
    end

    def ebay_product_variant_pictures(wombat_product)
      wombat_product["variants"].map do |variant|
        ebay_variant = {}
        ebay_variant[:VariationSpecificValue] = variant["options"].map { |name, value| value }
        ebay_variant[:PictureURL] = variant["images"].map { |image| image["url"].split('&').first }
        ebay_variant
      end
    end

    def ebay_product_variation_specifics(wombat_product)
      option_types = @wombat_product["variants"].map{ |v| v["options"] }
      variation_specifics = {}

      variation_specifics[:NameValueList] = @wombat_product["options"].map do |key|
        { Name: key, Value: option_types.map { |option_type| option_type[key] } }
      end

      variation_specifics
    end

    def ebay_product_variantions_set(wombat_product)
      ebay_variations_set = {}
      ebay_variations_set[:VariationSpecificsSet] = ebay_product_variation_specifics(wombat_product) if wombat_product["options"]
      ebay_variations_set[:Variation] = ebay_product_variants(wombat_product)
      ebay_variations_set[:Pictures] = {}
      ebay_variations_set[:Pictures][:VariationSpecificName] = wombat_product["options"].dup if wombat_product["options"]
      ebay_variations_set[:Pictures][:VariationSpecificPictureSet] = ebay_product_variant_pictures(wombat_product)
      ebay_variations_set
    end

    def ebay_product_listing_details(wombat_product)
      { start_time: wombat_product["available_on"] }
    end
end