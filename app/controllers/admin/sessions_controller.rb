class Admin::SessionsController < ApplicationController
  layout "clean" # 헤더/푸터 없는 깨끗한 레이아웃

  def new
    # 이미 로그인된 상태면 대시보드로 이동
    if session[:admin_id]
      redirect_to admin_root_path
    end
  end

  def create
    # 1. Check legacy ENV credentials
    admin_username = ENV.fetch("ADMIN_USERNAME", "admin@designd.co.kr")
    admin_password = ENV.fetch("ADMIN_PASSWORD", "djemals1234!")

    # 2. Check User model records
    user = User.find_by(email: params[:username])
    
    if (params[:username] == admin_username && params[:password] == admin_password) || 
       (user&.valid_password?(params[:password]) && (user.super_admin? || user.agency_admin?))
      session[:admin_id] = "admin"
      # If logged in via User model, we might want to sign them in via Devise too if needed
      # but for now we just keep the session[:admin_id] logic to maintain compatibility
      redirect_to admin_root_path, notice: "관리자 모드로 접속했습니다."
    else
      flash.now[:alert] = "아이디 또는 비밀번호가 올바르지 않습니다."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to new_admin_session_path, notice: "로그아웃되었습니다."
  end
end
