require 'json'

class Product
  def initialize(wombat_product, config={})
    @wombat_product = wombat_product
    @config = config
    @ebay_product = 
  end

  def ebay_product
    { country: :Country, currency: :Currency, listing_duration: :ListingDuration, location: :Location, dispatch_time_max: :DispatchTimeMax, paypal_email_address: :PayPalEmailAddress, condition_id: :ConditionID, payment_methods: :PaymentMethods }.each do |womabt_key, ebay_value|
      @ebay_product[ebay_value] = @config[womabt_key]
    end

    @ebay_product[:PrimaryCategory] = { CategoryID: @config[:category_id] }

    @ebay_product[:ReturnPolicy] = {}
    @ebay_product[:ReturnPolicy][:ReturnsAcceptedOption] = @config[:return_accepted_option]
    @ebay_product[:RefundPolicy][:RefundOption] = @config[:refund_option]
    @ebay_product[:RefundPolicy][:ReturnsWithinOption] = @config[:returns_within_option]
    @ebay_product[:RefundPolicy][:Description] = @config[:refund_policy_description]

    @ebay_product[:ShippingServiceOptions] = {}
    @ebay_product[:ShippingServiceOptions][:ShippingServicePriority] = @config[:shipping_service_priority]
    @ebay_product[:ShippingServiceOptions][:ShippingService] = @config[:shipping_service]
    @ebay_product[:ShippingServiceOptions][:ShippingServiceCost] = @config[:shipping_service_cost]

    { name: :Title, price: :StartPrice, description: :Description }.each do |wombat_key, ebay_value|
      @ebay_product[ebay_value] = @wombat_product[:wombat_key]
    end
    { item: @ebay_product }
  end
end