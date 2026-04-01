class Admin::PortfoliosController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_portfolio, only: [ :edit, :update, :destroy ]

  def index
    @portfolios = Portfolio.order(created_at: :desc)
    
    if params[:query].present?
      query = "%#{params[:query]}%"
      @portfolios = @portfolios.where("title LIKE ? OR client LIKE ? OR category LIKE ?", query, query, query)
    end

    @portfolios = @portfolios.page(params[:page]).per(20) rescue @portfolios
  end

  def new
    @portfolio = Portfolio.new
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)

    begin
      if @portfolio.save
        redirect_to admin_portfolios_path, notice: "포트폴리오가 성공적으로 등록되었습니다."
      else
        flash.now[:alert] = "입력 정보를 확인해주세요."
        render :new, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Failed to create portfolio: #{e.message}"
      flash.now[:alert] = "포트폴리오 저장 중 오류가 발생했습니다: #{e.message}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @portfolio.update(portfolio_params)
      redirect_to admin_portfolios_path, notice: "포트폴리오가 성공적으로 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @portfolio.destroy
    redirect_to admin_portfolios_path, notice: "포트폴리오가 삭제되었습니다."
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end

  def portfolio_params
    params.require(:portfolio).permit(:title, :description, :category, :client, :project_date, :image_url, :image, :mobile_image)
  end
end
