class Admin::AgenciesController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_agency, only: [:show, :edit, :update, :destroy]

  def index
    if session[:admin_id] == "admin" || current_user&.super_admin?
      @agencies = Agency.preload(:owner).order(created_at: :desc)
    else
      # 1. 내가 소유하거나 관리자인 에이전시 ID 추출
      my_agency_ids = Agency.where(owner_id: current_user.id)
                            .or(Agency.where("admin_ids LIKE ?", "%\"#{current_user.id}\"%")).pluck(:id)
      
      # 2. 내 에이전시들 + 내 에이전시를 부모로 둔 하위 에이전시들 조회
      @agencies = Agency.where(id: my_agency_ids)
                        .or(Agency.where(parent_agency_id: my_agency_ids))
                        .preload(:owner).order(created_at: :desc)
    end
  end

  def show
  end

  def new
    @agency = Agency.new
    @available_owners = User.where(role: 'owner') # 이미 owner 권한이 있는 유저들
  end

  def create
    @agency = Agency.new(agency_params)
    if @agency.save
      redirect_to admin_agencies_path, notice: "에이전시가 성공적으로 등록되었습니다."
    else
      @available_owners = User.where(role: 'owner')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_owners = User.all
  end

  def update
    if @agency.update(agency_params)
      redirect_to admin_agencies_path, notice: "에이전시 정보가 수정되었습니다."
    else
      @available_owners = User.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @agency.destroy
    redirect_to admin_agencies_path, notice: "에이전시가 삭제되었습니다."
  end

  private

  def set_agency
    @agency = Agency.find(params[:id])
    
    # 권한 체크
    is_master = session[:admin_id] == "admin" || current_user&.super_admin?
    is_owner_or_admin = @agency.owner_id == current_user&.id || @agency.admin_ids.include?(current_user&.id.to_s)
    
    # 부모 에이전시 권한 체크 (내가 이 에이전시의 부모 에이전시 소유자라면 접근 가능)
    parent_agency = @agency.parent_agency
    is_parent_owner = parent_agency.present? && (parent_agency.owner_id == current_user&.id || parent_agency.admin_ids.include?(current_user&.id.to_s))

    unless is_master || is_owner_or_admin || is_parent_owner
      redirect_to admin_agencies_path, alert: "해당 에이전시에 대한 권한이 없습니다."
    end
  end

  def agency_params
    params.require(:agency).permit(:name, :subdomain, :owner_id, :active, :settings, :commission_rate, admin_ids: [])
  end
end
