class Admin::OrdersController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_order, only: [:show, :update_status]

  def index
    @orders = Order.preload(:user).order(created_at: :desc)
    
    # Scoping for Agency Owner/Admin
    unless session[:admin_id] == "admin" || current_user&.super_admin?
      @orders = @orders.where(agency_id: current_user.agency_id) # Primary agency if linked
      # or if they are owners of specific agencies
      owned_agency_ids = Agency.where(owner_id: current_user.id).pluck(:id)
      managed_agency_ids = Agency.where("admin_ids LIKE ?", "%\"#{current_user.id}\"%").pluck(:id)
      @orders = Order.where(agency_id: owned_agency_ids + managed_agency_ids).preload(:user).order(created_at: :desc)
    end

    if params[:status].present?
      @orders = @orders.where(status: params[:status])
    end

    if params[:query].present?
      query = "%#{params[:query]}%"
      @orders = @orders.left_outer_joins(:user).where("orders.id LIKE ? OR users.email LIKE ? OR users.name LIKE ?", query, query, query)
    end

    @orders = @orders.page(params[:page]).per(20) rescue @orders
  end

  def show
  end

  def update_status
    if @order.update(status: params[:status])
      redirect_to admin_order_path(@order), notice: "주문 상태가 변경되었습니다."
    else
      redirect_to admin_order_path(@order), alert: "상태 변경에 실패했습니다."
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
    
    # Authorization Check
    unless session[:admin_id] == "admin" || current_user&.super_admin?
      owned_agency_ids = Agency.where(owner_id: current_user.id).pluck(:id)
      managed_agency_ids = Agency.where("admin_ids LIKE ?", "%\"#{current_user.id}\"%").pluck(:id)
      unless (owned_agency_ids + managed_agency_ids).include?(@order.agency_id)
        redirect_to admin_orders_path, alert: "해당 주문에 대한 권한이 없습니다."
      end
    end
  end
end
