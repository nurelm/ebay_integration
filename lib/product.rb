require 'json'

class Product
  def initialize(wombat_product, config={})
    @wombat_product = wombat_product["product"]
    @config = config
    @ebay_product = {}
  end

  def search_params
    { start_time_from: @config["ebay_start_time_from"], start_time_to: @config["ebay_start_time_to"], include_variations: 'true', detail_level: 'ReturnAll', pagination: { entries_per_page: 25, page_number: @config['ebay_page_number'] } }
  end

  def ebay_product
    { "country" => :Country, "currency" => :Currency, "listing_duration" => :ListingDuration, "location" => :Location, "dispatch_time_max" => :DispatchTimeMax, "paypal_email_address" => :PayPalEmailAddress, "condition_id" => :ConditionID }.each do |womabt_key, ebay_value|
      @ebay_product[ebay_value] = @config[womabt_key] if @config[womabt_key]
    end

    @ebay_product[:ItemID] = @wombat_product["ebay_item_id"] if @wombat_product["ebay_item_id"]
    @ebay_product[:ApplicationData] = @wombat_product["id"]

    @ebay_product[:PrimaryCategory] = { CategoryID: @config["category_id"] } if @config["category_id"]

    @ebay_product[:ReturnPolicy] = JSON.parse(@config["return_policy"]) if @config["return_policy"]

    @ebay_product[:ShippingDetails] = {} if @config["shipping_service_options"] || @config["shipping_type"]
    @ebay_product[:ShippingDetails][:ShippingType] = @config["shipping_type"] if @config["shipping_type"]
    @ebay_product[:ShippingDetails][:ShippingServiceOptions] = JSON.parse(@config["shipping_service_options"]) if @config["shipping_service_options"]

    @ebay_product[:PaymentMethods] = @config["payment_methods"].split(',').map(&:strip) if @config["payment_methods"]

    @ebay_product[:PictureDetails] = {}
    @ebay_product[:PictureDetails][:PictureURL] = @wombat_product["images"].map { |image| image["url"] } if @wombat_product["images"].is_a?(Array)

    @ebay_product[:ItemSpecifics] = {}
    @ebay_product[:ItemSpecifics][:NameValueList] = @wombat_product["properties"].map { |name, value| { Name: name, Value: value } } if @wombat_product["properties"].is_a?(Array)

    if @wombat_product["variants"].is_a?(Array) && @wombat_product["variants"].first
      @ebay_product[:Variations] = {}
      @ebay_product[:Variations][:VariationSpecificsSet] = {}

      option_types = @wombat_product["variants"].map{ |v| v["options"] }
      @ebay_product[:Variations][:VariationSpecificsSet][:NameValueList] = @wombat_product["options"].map do |key|
        { Name: key, Value: option_types.map { |option_type| option_type[key] } }
      end

      @ebay_product[:Variations][:Variation] = @wombat_product["variants"].map do |variant|
        ebay_variant = {}
        { "price" => :StartPrice, "quantity" => :Quantity, "sku" => :SKU }.each do |wombat_key, ebay_value|
          ebay_variant[ebay_value] = variant[wombat_key]
        end

        ebay_variant[:Deleted] = true if variant["deleted_at"].is_a?(String) && !variant["deleted_at"].strip.empty?

        ebay_variant[:VariationSpecifics] = {}
        ebay_variant[:VariationSpecifics][:NameValueList] = variant["options"].map { |name, value| { Name: name, Value: value } }

        ebay_variant
      end

      @ebay_product[:Variations][:Pictures] = {}
      @ebay_product[:Variations][:Pictures][:VariationSpecificName] = @wombat_product["options"].dup

      @ebay_product[:Variations][:Pictures][:VariationSpecificPictureSet] = @wombat_product["variants"].map do |variant|
        ebay_variant = {}
        ebay_variant[:VariationSpecificValue] = variant["options"].map { |name, value| value }
        ebay_variant[:PictureURL] = variant["images"].map { |image| image["url"] }
        ebay_variant
      end
    else
      @ebay_product[:Quantity] = @wombat_product["quantity"]
      @ebay_product[:StartPrice] = @wombat_product["price"]
    end

    @ebay_product[:listing_details] = { }
    @ebay_product[:listing_details][:start_time] = @wombat_product["available_on"]

    { "name" => :Title, "sku" => :SKU, "description" => :Description }.each do |wombat_key, ebay_value|
      @ebay_product[ebay_value] = @wombat_product[wombat_key]
    end

    { item: @ebay_product }
  end

  def ebay_product_inventory
    @ebay_product[:ItemID] = @wombat_product["ebay_item_id"]

    if @wombat_product["variants"].is_a?(Array) && @wombat_product["variants"].first
      @ebay_product[:Variations] = {}
      @ebay_product[:Variations][:VariationSpecificsSet] = {}

      @ebay_product[:Variations][:Variation] = @wombat_product["variants"].map do |variant|
        ebay_variant = {}

        ebay_variant[:Quantity] = variant['quantity']

        ebay_variant[:VariationSpecifics] = {}
        ebay_variant[:VariationSpecifics][:NameValueList] = variant["options"].map { |name, value| { Name: name, Value: value } }

        ebay_variant
      end
    else
      @ebay_product[:Quantity] = @wombat_product["quantity"]
    end

    { item: @ebay_product }
  end

  def self.wombat_product_hash(ebay_product)
    wombat_product = {}

    { "id" => :item_id, "ebay_item_id" => :item_id, "name" => :title, "sku" => :sku, "description" => :description }.each do |wombat_key, ebay_value|
      wombat_product[wombat_key] = ebay_product[ebay_value]
    end

    wombat_product[:images] = []
    wombat_product[:images] = [ebay_product[:picture_details][:picture_url]].flatten.map { |picture_url| { url: picture_url } } if ebay_product[:picture_details][:picture_url]

    if ebay_product[:variations] && ebay_product[:variations][:variation] && !ebay_product[:variations][:variation].empty?
      wombat_product[:variants] = [ebay_product[:variations][:variation]].flatten.map do |variantion|
        wombat_variant = {}

        { sku: :SKU, start_price: :price, quantity: :quantity }.each do |wombat_key, ebay_value|
          wombat_variant[wombat_key] = variantion[ebay_value]
        end

        wombat_variant[:options] = {}

        variantion[:variation_specifics][:name_value_list].each do |name_value|
          wombat_variant[:options].merge({ name_value[:name] => name_value[:value] })
        end

        wombat_variant
      end
    else
      wombat_product[:quantity] = ebay_product[:quantity]
      wombat_product[:start_price] = ebay_product[:price]
    end

    wombat_product
  end
end