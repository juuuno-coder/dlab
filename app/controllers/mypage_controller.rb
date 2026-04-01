class MypageController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @orders = current_user.orders.order(created_at: :desc).limit(5)
    @quotes = current_user.quotes.order(created_at: :desc)
    @liked_templates = current_user.liked_templates.limit(6)
    @owned_agencies = Agency.where(owner_id: current_user.id).order(created_at: :desc)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to mypage_path, notice: '프로필이 업데이트되었습니다.'
    else
      render :edit
    end
  end

  def wishlist
    @liked_templates = current_user.liked_templates.order('likes.created_at DESC')
  end

  def orders
    @orders = current_user.orders.order(created_at: :desc)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end
end
