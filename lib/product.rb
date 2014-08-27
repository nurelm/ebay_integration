require 'json'

class Product
  def initialize(wombat_product, config={})
    @wombat_product = wombat_product
    @config = config
    @ebay_product = Hash.new
  end

  def ebay_product
    { country: :Country, currency: :Currency, listing_duration: :ListingDuration, location: :Location, dispatch_time_max: :DispatchTimeMax, paypal_email_address: :PayPalEmailAddress, condition_id: :ConditionID, postal_code: :PostalCode }.each do |womabt_key, ebay_value|
      @ebay_product[ebay_value] = @config[womabt_key]
    end

    @ebay_product[:PrimaryCategory] = { CategoryID: @config[:category_id] }

    @ebay_product[:ReturnPolicy] = @config[:return_policy].dup

    @ebay_product[:ShippingDetails] = {}
    @ebay_product[:ShippingDetails][:ShippingType] = @config[:shipping_type]
    @ebay_product[:ShippingServiceOptions] = @config[:shipping_service_options].dup

    @ebay_product[:PaymentMethods] = @config[:payment_methods].split(',').map(&:strip)

    @ebay_product[:PictureDetails] = {}
    @ebay_product[:PictureDetails][:PictureURL] = @wombat_product[:images].map { |image| image[:url] }

    @ebay_product[:ItemSpecifics] = {}
    @ebay_product[:ItemSpecifics][:NameValueList] = @wombat_product[:properties].map { |name, value| { Name: name, Value: value } }

    @ebay_product[:Variations] = {}
    @ebay_product[:Variations][:VariationSpecificsSet] = {}
    @ebay_product[:Variations][:VariationSpecificsSet][:NameValueList] = {}
    @ebay_product[:Variations][:VariationSpecificsSet][:NameValueList][:Name] = @wombat_product[:options].dup

    @ebay_product[:Variations][:Variation] = @wombat_product[:variants].map do |variant|
      ebay_variant = {}
      { name: :Title, price: :BuyItNowPrice, quantity: :Quantity, sku: :SKU }.each do |wombat_key, ebay_value|
        ebay_variant[:ebay_value] = variant[:wombat_key]
      end

      ebay_variant[:VariationSpecifics] = {}
      ebay_variant[:VariationSpecifics][:NameValueList] = variant[:options].map { |name, value| {Name: name, Value: value} }

      ebay_variant
    end

    @ebay_product[:Variations][:Pictures] = {}
    @ebay_product[:Variations][:Pictures][:VariationSpecificName] = @wombat_product[:options].dup

    @ebay_product[:Variations][:Pictures][:VariationSpecificPictureSet] = @wombat_product[:variants].map do |variant|
      ebay_variant = {}
      ebay_variant[:VariationSpecificValue] = variant[:options].map { |name, value| value }
      ebay_variant[:PictureUrl] = variant[:images].map { |image| image[:url] }
      ebay_variant
    end

    { name: :Title, price: :BuyItNowPrice, description: :Description }.each do |wombat_key, ebay_value|
      @ebay_product[ebay_value] = @wombat_product[wombat_key]
    end
    { item: @ebay_product }
  end
end