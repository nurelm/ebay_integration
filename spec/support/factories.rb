module Factories
  # Collection of stuff to test against
  class << self
    def line_item
      { transaction_price: '5.00',
        quantity_purchased: '1',
        taxes: {total_tax_amount: '0.0' },
        buyer: { email: 'lol@cox.newt',
                 user_first_name: 'Testfirst',
                 user_last_name: 'Testlast' },
        item: { title: 'Brand New Product!',
                item_id: '12345',
                sku: 'thisissku' } }
    end

    def order
      {
        order_id: '110162297659-27485126001',
        order_status: 'Completed',
        adjustment_amount: '0.0',
        amount_paid: '2.0',
        amount_saved: '0.0',
        created_time: '2015-05-21T22:37:01.000Z',
        payment_methods: 'PayPal',
        seller_email: 'cooperlebrun@gmail.com',
        shipping_service_selected: { shipping_service: 'USPSFirstClass',
                                     shipping_service_cost: '1.0' },
        subtotal: '1.0',
        total: '2.0',
        external_transaction: { external_transaction_id: '91681732GU4308121',
                                external_transaction_time: '2015-05-21T23:22:15.000Z',
                                fee_or_credit_amount: '0.36',
                                payment_or_refund_amount: '2.0',
                                external_transaction_status: 'Pending' },
        buyer_user_id: 'testuser_gpsmatty',
        integrated_merchant_credit_card_enabled: false,
        eias_token: 'nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZeDoAidj6x9nY+seQ==',
        payment_hold_status: 'PaymentReview',
        is_multi_leg_shipping: false,
        seller_user_id: 'testuser_clebrun',
        seller_eias_token: 'nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhDZaFpwqdj6x9nY+seQ==',
        cancel_status: 'NotApplicable',
        extended_order_id: '110162297659-27485126001!632290000',
        checkout_status: checkout_status,
        shipping_details: shipping_details,
        shipping_address: shipping_address,
        monetary_details: monetary_details,
        transaction_array: transaction_array
      }
    end

    def checkout_status
      {
        e_bay_payment_status: 'PayPalPaymentInProcess',
        last_modified_time: '2015-05-21T23:22:16.000Z',
        payment_method: 'PayPal',
        status: 'Complete',
        integrated_merchant_credit_card_enabled: false
      }
    end

    def shipping_details
      {
        sales_tax: { sales_tax_percent: '0.0',
         sales_tax_state: 'CA',
         shipping_included_in_tax: false,
         sales_tax_amount: '0.0' },
         shipping_service_options: [{ shipping_service: 'USPSFirstClass',
          shipping_service_cost: '1.0',
          shipping_service_priority: '1',
          expedited_service: false,
          shipping_time_min: '2',
          shipping_time_max: '6' },
          { shipping_service: 'UPSNextDayAir',
           shipping_service_cost: '1.0',
           shipping_service_priority: '2',
           expedited_service: true,
           shipping_time_min: '1',
           shipping_time_max: '1' }],
        selling_manager_sales_record_number: '100',
        tax_table: { tax_jurisdiction: { sales_tax_percent: '0.0',
         shipping_included_in_tax: false } },
         get_it_fast: false
      }
    end

    def shipping_address
      {
        name: 'Test User',
        street1: 'address',
        street2: nil,
        city_name: 'city',
        state_or_province: 'WA',
        country: 'US',
        country_name: 'United States',
        phone: '1 800 111 1111',
        postal_code: '98102',
        address_id: '7544652',
        address_owner: 'eBay',
        external_address_id: nil
      }
    end

    def monetary_details
      {
        payments: { payment: {
          payment_status: 'Pending',
          payer: 'testuser_gpsmatty',
          payee: 'testuser_clebrun',
          payment_time: '2015-05-21T23:22:15.000Z',
          payment_amount: '2.0',
          reference_id: '91681732GU4308121',
          fee_or_credit_amount: '0.36' } }
      }
    end

    def transaction_array
      {
        transaction: { buyer: { email: 'gpsmatty@gmail.com',
          user_first_name: 'Test',
          user_last_name: 'User' },
          shipping_details: { selling_manager_sales_record_number: '100' },
          created_date: '2015-05-21T22:37:01.000Z',
          item: { item_id: '110162297659',
           site: 'US',
           title: 'foobar',
           sku: 'thisissku' },
           quantity_purchased: '1',
           status: { payment_hold_status: 'PaymentReview',
            inquiry_status: 'NotApplicable',
            return_status: 'NotApplicable' },
            transaction_id: '27485126001',
            transaction_price: '1.0',
            final_value_fee: '0.1',
            transaction_site_id: 'US',
            platform: 'eBay',
            taxes: { total_tax_amount: '0.0',
             tax_details: [{ imposition: 'SalesTax',
              tax_description: 'SalesTax',
              tax_amount: '0.0',
              tax_on_subtotal_amount: '0.0',
              tax_on_shipping_amount: '0.0',
              tax_on_handling_amount: '0.0' },
              { imposition: 'WasteRecyclingFee',
               tax_description: 'ElectronicWasteRecyclingFee',
               tax_amount: '0.0' }] },
               actual_shipping_cost: '1.0',
               actual_handling_cost: '0.0',
               order_line_item_id: '110162297659-27485126001',
               extended_order_id: '110162297659-27485126001!632290000' }
      }
    end
  end
end
