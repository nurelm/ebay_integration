require 'json'

class Order
  def initialize(config={})
    @config = config
  end

  def search_params
    { mod_time_from: @config["ebay_mod_time_from"], mod_time_to: Time.now.to_s, include_final_value_fee: 'true', detail_level: 'ReturnAll', pagination: { entries_per_page: 25, page_number: @config['ebay_page_number'] } }
  end

  def self.wombat_order_hash(ebay_order)
    wombat_order = {}

    { "id" => :order_id, "ebay_order_id" => :order_id, "placed_on" => :created_time }.each do |wombat_key, ebay_value|
      wombat_order[wombat_key] = ebay_order[ebay_value]
    end

    wombat_order["status"] = ebay_order[:checkout_status][:status]

    wombat_order["shipping_address"] = {}

    { "first_name" => :name, "address1" => :street1, "address2" => :street2, "city" => :city, "state" => :state, "zipcode" => :postal_code, "country" => :country, "phone" => :phone }.each do |wombat_key, ebay_value|
      wombat_order["shipping_address"][wombat_key] = ebay_order[:shipping_address][ebay_value]
    end

    wombat_order["billing_address"] = wombat_order["shipping_address"].dup

    wombat_order["line_items"] = [ebay_order[:transaction_array][:transactions]].flatten.map do |transaction|
      line_item = {}

      line_item["price"] = transaction[:transaction_price]
      line_item["quantity"] = transaction[:quantity_purchased]

      line_item["title"] = transaction[:item][:title]
      line_item["ebay_product_id"] = transaction[:item][:item_id]

      line_item
    end if ebay_order[:transaction_array]

    wombat_order["totals"] = {}
    wombat_order["totals"]["adjustment"] = ebay_order[:adjustment_amount]
    wombat_order["totals"]["tax"] = ebay_order[:sale_tax][:sale_tax_amount]
    wombat_order["totals"]["shipping"] = ebay_order[:taxes][:total_tax_amount]
    wombat_order["totals"]["item"] = ebay_order[:subtotal]
    wombat_order["totals"]["total"] = ebay_order[:total]

    wombat_order["payments"] = [ebay_order[:monetary_details][:payments][:payment]].flatten.map do |payment|
      womabt_payment = {}

      wombat_payment["status"] = payment[:payment_status]
      wombat_payment["amount"] = payment[:payment_amount]

      wombat_payment["payment_method"] = ebay_order[:checkout_status][:payment_method]
    end if ebay_order[:monetary_details] && ebay_order[:monetary_details][:payments] && ebay_order[:monetary_details][:payments][:payment]

    wombat_order
  end
end