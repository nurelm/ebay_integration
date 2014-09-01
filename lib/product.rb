require 'json'

class Product
  def initialize(wombat_product, config={})
    @wombat_product = wombat_product["product"]
    @config = config
    @ebay_product = Hash.new
  end

  def ebay_product
    { "country" => :Country, "currency" => :Currency, "listing_duration" => :ListingDuration, "location" => :Location, "dispatch_time_max" => :DispatchTimeMax, "paypal_email_address" => :PayPalEmailAddress, "condition_id" => :ConditionID }.each do |womabt_key, ebay_value|
      @ebay_product[ebay_value] = @config[womabt_key]
    end

    @ebay_product[:PrimaryCategory] = { CategoryID: @config["category_id"] }

    @ebay_product[:ReturnPolicy] = JSON.parse(@config["return_policy"])

    @ebay_product[:ShippingDetails] = {}
    @ebay_product[:ShippingDetails][:ShippingType] = @config["shipping_type"]
    @ebay_product[:ShippingDetails][:ShippingServiceOptions] = JSON.parse(@config["shipping_service_options"])

    @ebay_product[:PaymentMethods] = @config["payment_methods"].split(',').map(&:strip)

    @ebay_product[:PictureDetails] = {}
    @ebay_product[:PictureDetails][:PictureURL] = @wombat_product["images"].map { |image| image["url"] } if @wombat_product["images"].is_a?(Array)

    @ebay_product[:ItemSpecifics] = {}
    @ebay_product[:ItemSpecifics][:NameValueList] = @wombat_product["properties"].map { |name, value| { Name: name, Value: value } } if @wombat_product["properties"].is_a?(Array)

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

      ebay_variant[:Deleted] = true if variant["deleted_at"].is_a?(String) && variant["deleted_at"].strip.empty?

      ebay_variant[:VariationSpecifics] = {}
      ebay_variant[:VariationSpecifics][:NameValueList] = variant["options"].map { |name, value| { Name: name, Value: value } }

      ebay_variant
    end if @wombat_product["variants"].is_a?(Array)

    @ebay_product[:Variations][:Pictures] = {}
    @ebay_product[:Variations][:Pictures][:VariationSpecificName] = @wombat_product["options"].dup

    @ebay_product[:Variations][:Pictures][:VariationSpecificPictureSet] = @wombat_product["variants"].map do |variant|
      ebay_variant = {}
      ebay_variant[:VariationSpecificValue] = variant["options"].map { |name, value| value }
      ebay_variant[:PictureURL] = variant["images"].map { |image| image["url"] }
      ebay_variant
    end if @wombat_product["variants"].is_a?(Array)

    { "name" => :Title, "sku" => :SKU, "description" => :Description }.each do |wombat_key, ebay_value|
      @ebay_product[ebay_value] = @wombat_product[wombat_key]
    end
    if !@wombat_product["variants"].is_a?(Array) || @wombat_product["variants"].exists?
      @ebay_product[:Quantity] = @wombat_product["quantity"]
      @ebay_product[:StartPrice] = @wombat_product["price"]
    end

    { item: @ebay_product }
  end
end