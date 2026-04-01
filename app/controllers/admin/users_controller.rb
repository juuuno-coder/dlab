class Admin::UsersController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.order(created_at: :desc)
    
    # Scoping for Agency Owner/Admin
    unless session[:admin_id] == "admin" || current_user&.super_admin?
      my_owned_agency_ids = Agency.where(owner_id: current_user.id).pluck(:id)
      my_managed_agency_ids = Agency.where("admin_ids LIKE ?", "%\"#{current_user.id}\"%").pluck(:id)
      parent_agency_ids = (my_owned_agency_ids + my_managed_agency_ids).uniq
      
      # 내 에이전시들 + 내 에이전시의 하위 에이전시들 ID 합치기
      child_agency_ids = Agency.where(parent_agency_id: parent_agency_ids).pluck(:id)
      target_agency_ids = (parent_agency_ids + child_agency_ids).uniq
      
      @users = @users.where(agency_id: target_agency_ids)
    end

    if params[:query].present?
      query = "%#{params[:query]}%"
      @users = @users.where("email LIKE ? OR name LIKE ?", query, query)
    end

    @users = @users.page(params[:page]).per(20) rescue @users
  end

  def show
    @orders = @user.orders.order(created_at: :desc)
    
    # Authorization Check
    unless session[:admin_id] == "admin" || current_user&.super_admin?
      my_owned_agency_ids = Agency.where(owner_id: current_user.id).pluck(:id)
      my_managed_agency_ids = Agency.where("admin_ids LIKE ?", "%\"#{current_user.id}\"%").pluck(:id)
      parent_agency_ids = (my_owned_agency_ids + my_managed_agency_ids).uniq
      child_agency_ids = Agency.where(parent_agency_id: parent_agency_ids).pluck(:id)
      
      target_agency_ids = (parent_agency_ids + child_agency_ids).uniq
      
      unless target_agency_ids.include?(@user.agency_id)
        redirect_to admin_users_path, alert: "해당 회원 정보를 볼 권한이 없습니다."
      end
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "회원 정보가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "회원이 삭제되었습니다."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
