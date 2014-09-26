require 'json'

class Order
  WOMBAT_ORDER_INITIAL_VALUES_MAPPING = { "id" => :order_id, "ebay_order_id" => :order_id, "placed_on" => :created_time }
  WOMBAT_ORDER_SHIPPING_VALUES_MAPPING = { "first_name" => :name, "address1" => :street1, "address2" => :street2, "city" => :city, "state" => :state, "zipcode" => :postal_code, "country" => :country, "phone" => :phone }

  def initialize(config={})
    @config = config
  end

  def search_params
    { mod_time_from: @config["ebay_mod_time_from"], mod_time_to: Time.now.to_s, include_final_value_fee: 'true', detail_level: 'ReturnAll', pagination: { entries_per_page: 25, page_number: @config['ebay_page_number'] } }
  end

  def self.wombat_order_hash(ebay_order)
    wombat_order = wombat_order_initial_values(ebay_order)
    wombat_order["status"] = wombat_order_status(ebay_order)
    wombat_order["shipping_address"] = wombat_order_shipping_address(ebay_order)
    wombat_order["billing_address"] = wombat_order["shipping_address"].dup
    wombat_order["line_items"] = wombat_order_line_items(ebay_order) if line_items_present?(ebay_order)
    wombat_order["totals"] = wombat_order_totals(ebay_order)
    wombat_order["payments"] = wombat_order_payments(ebay_order) if payments_present?(ebay_order)
    wombat_order
  end

  private

    def self.wombat_order_initial_values(ebay_order)
      wombat_order = {}

      WOMBAT_ORDER_INITIAL_VALUES_MAPPING.each do |wombat_key, ebay_value|
        wombat_order[wombat_key] = ebay_order[ebay_value]
      end

      wombat_order
    end

    def self.wombat_order_shipping_address(ebay_order)
      shipping_address = {}

      WOMBAT_ORDER_SHIPPING_VALUES_MAPPING.each do |wombat_key, ebay_value|
        shipping_address[wombat_key] = ebay_order[:shipping_address][ebay_value]
      end

      shipping_address
    end

    def self.wombat_order_status(ebay_order)
      ebay_order[:checkout_status][:status]
    end

    def self.wombat_order_line_items(ebay_order)
      [ebay_order[:transaction_array][:transaction]].flatten.map { |transaction| wombat_order_line_item(transaction) }
    end

    def self.wombat_order_line_item(transaction)
      { "price" => transaction[:transaction_price], "quantity" => transaction[:quantity_purchased], "title" => transaction[:item][:title], "ebay_product_id" => transaction[:item][:item_id] }
    end

    def self.line_items_present?(ebay_order)
      ebay_order[:transaction_array]
    end

    def self.wombat_order_payments(ebay_order)
      [ebay_order[:monetary_details][:payments][:payment]].flatten.map { |payment| wombat_order_payment(ebay_order, payment) }
    end

    def self.wombat_order_payment(ebay_order, payment)
      { "status" => payment[:payment_status], "amount" => payment[:payment_amount], "payment_method" => ebay_order[:checkout_status][:payment_method] }
    end

    def self.payments_present?(ebay_order)
      ebay_order[:monetary_details] && ebay_order[:monetary_details][:payments] && ebay_order[:monetary_details][:payments][:payment]
    end

    def self.wombat_order_totals(ebay_order)
      { "adjustment" => ebay_order[:adjustment_amount], "tax" => ebay_order[:shipping_details][:sales_tax][:sales_tax_amount], "shipping" => ebay_order[:shipping_service_selected][:shipping_service_cost], "item" => ebay_order[:subtotal], "order" => ebay_order[:total] }
    end
end