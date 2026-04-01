json.extract! order, :id, :product_id, :customer_name, :amount, :status, :payment_key, :order_uid, :created_at, :updated_at
json.url order_url(order, format: :json)
