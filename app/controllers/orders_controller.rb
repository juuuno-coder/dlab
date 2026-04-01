class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: %i[ show edit update destroy ]

  # GET /orders or /orders.json
  def index
    redirect_to mypage_orders_path
  end

  # GET /orders/1 or /orders/1.json
  def show
    # @order is already set by set_order which is now scoped to current_user
  end

  # GET /orders/new
  def new
    # Legacy support or remove? Keeping for now but strictly scoped
    @order = current_user.orders.build
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    @order = current_user.orders.build(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    if @order.pending?
      @order.update!(status: 'cancelled')
      notice = "주문이 취소되었습니다."
    else
      @order.destroy!
      notice = "주문 내역이 삭제되었습니다."
    end

    respond_to do |format|
      format.html { redirect_to mypage_orders_path, notice: notice, status: :see_other }
      format.json { head :no_content }
    end
  end

  # 장바구니에서 주문 생성
  def create_from_cart
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "로그인이 필요합니다."
      return
    end

    cart = current_user.cart
    unless cart&.cart_items&.any?
      redirect_to cart_path, alert: "장바구니가 비어있습니다."
      return
    end

    # 주문 생성
    @order = current_user.orders.build(
      status: 'pending',
      total_amount: 0
    )

    # 장바구니 아이템을 주문 아이템으로 변환
    cart.cart_items.each do |cart_item|
      @order.order_items.build(
        design_template: cart_item.design_template,
        quantity: cart_item.quantity,
        price: cart_item.design_template.price
      )
    end

    # 총액 계산
    @order.total_amount = @order.calculate_total

    if @order.save
      # 장바구니 비우기
      cart.cart_items.destroy_all
      
      # 결제 페이지로 리다이렉트 (PortOne 연동)
      redirect_to @order, notice: "주문이 생성되었습니다. 결제를 진행해주세요."
    else
      redirect_to cart_path, alert: "주문 생성에 실패했습니다."
    end
  end

  # Payment Success Handling
  def success
    payment_key = params[:paymentKey]
    order_id = params[:orderId]
    amount = params[:amount]
    product_id = params[:product_id]

    @product = Product.find(product_id)

    # 실제로는 여기서 토스 페이먼츠 승인 API (POST https://api.tosspayments.com/v1/payments/confirm)를 호출해야 함
    # 현재는 테스트를 위해 생략하고 바로 주문 생성

    @order = Order.new(
      product: @product,
      customer_name: "Test Customer", # 로그인 기능 연동 시 current_user.name 등 사용
      amount: amount,
      status: "paid",
      payment_key: payment_key,
      order_uid: order_id
    )

    if @order.save
      @order.complete_payment! # Agency 생성 및 유저 권한 업그레이드 실행
      redirect_to @order, notice: "결제가 성공적으로 완료되었습니다!"
    else
      redirect_to mypage_orders_path, alert: "결제 처리에 실패했습니다."
    end
  end

  def fail
    error_code = params[:code]
    error_msg = params[:message]
    
    redirect_to products_path, alert: "결제 실패: #{error_msg} (#{error_code})"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_user.orders.find(params.expect(:id))
    rescue ActiveRecord::RecordNotFound
      redirect_to mypage_orders_path, alert: "주문을 찾을 수 없습니다."
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.expect(order: [ :product_id, :customer_name, :amount, :status, :payment_key, :order_uid ])
    end
end
