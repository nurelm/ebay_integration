require 'json'

class Inventory
  def initialize(wombat_inventory, config={})
    @wombat_inventory = wombat_inventory["product"]
    @config = config
    @ebay_inventory = {}
  end

  def ebay_inventory
    @ebay_inventory[:ItemID] = @wombat_product["ebay_item_id"]
    @ebay_inventory[:SKU] = @wombat_product["ebay_sku"] if @wombat_product["ebay_sku"]
    @ebay_inventory[:Quantity] = @wombat_product["quantity"]

    { inventory_status: @ebay_inventory }
  end

  def self.wombat_inventories_hash(ebay_product)
    wombat_inventories = {}

    if ebay_product[:variations] && ebay_product[:variations][:variation] && !ebay_product[:variations][:variation].empty?
      wombat_inventories[:inventories] = [ebay_product[:variations][:variation]].flatten.map do |variation|
        wombat_inventory = {}

        wombat_inventory["id"] = "#{ebay_product[:item_id]} - #{variation[:sku]}"
        wombat_inventory["product_id"] = ebay_product[:application_data] || ebay_product[:item_id]
        wombat_inventory["ebay_product_id"] = ebay_product[:item_id]

        { ebay_sku: :sku, quantity: :quantity }.each do |wombat_key, ebay_value|
          wombat_inventory[wombat_key] = variation[ebay_value] if variation[ebay_value]
        end

        wombat_inventory
      end
    else
      wombat_inventory = {}

      wombat_inventory["id"] = ebay_product[:item_id]
      wombat_inventory["product_id"] = ebay_product[:application_data] || ebay_product[:item_id]

      { ebay_sku: :sku, quantity: :quantity, ebay_product_id: :item_id }.each do |wombat_key, ebay_value|
        wombat_inventory[wombat_key] = ebay_product[ebay_value] if ebay_product[ebay_value]
      end

      wombat_inventories = { inventories: [wombat_inventory] }
    end

    wombat_inventories[:inventories]
  end
end