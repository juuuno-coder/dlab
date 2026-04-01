class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @cart = current_cart
    @items = @cart.cart_items.includes(:item)
  end

  def add_item
    # Polymorphic adding
    item_type = params[:item_type] || 'DesignTemplate'
    item_id = params[:item_id]
    
    @cart = current_cart
    
    # Check if item exists in cart
    current_item = @cart.cart_items.find_by(item_type: item_type, item_id: item_id)
    
    if current_item
      current_item.increment!(:quantity)
    else
      @cart.cart_items.create(item_type: item_type, item_id: item_id, quantity: 1)
    end
    
    redirect_to cart_path, notice: '장바구니에 상품을 담았습니다.'
  end

  def remove_item
    item = current_cart.cart_items.find(params[:id])
    item.destroy
    redirect_to cart_path, notice: '상품이 삭제되었습니다.'
  end

  private

  def current_cart
    if current_user.cart.nil?
      Cart.create(user: current_user)
    else
      current_user.cart
    end
  end
end
