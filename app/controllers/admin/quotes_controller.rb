require "prawn"
require "prawn/table"

class Admin::QuotesController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_quote, only: [ :show, :edit, :update, :destroy ]

  def index
    @quotes = Quote.order(created_at: :desc)
    
    # Scoping for Agency Owner/Admin
    unless session[:admin_id] == "admin" || current_user&.super_admin?
      owned_agency_ids = Agency.where(owner_id: current_user.id).pluck(:id)
      managed_agency_ids = Agency.where("admin_ids LIKE ?", "%\"#{current_user.id}\"%").pluck(:id)
      @quotes = Quote.where(agency_id: owned_agency_ids + managed_agency_ids).order(created_at: :desc)
    end

    if params[:status].present?
      @quotes = @quotes.where(status: params[:status])
    end

    if params[:query].present?
      query = "%#{params[:query]}%"
      @quotes = @quotes.where("contact_name LIKE ? OR company_name LIKE ? OR email LIKE ?", query, query, query)
    end

    @quotes = @quotes.page(params[:page]).per(20) rescue @quotes
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        pdf = generate_quote_pdf(@quote)
        send_data pdf.render,
          filename: "quote_#{@quote.id}_#{Date.today}.pdf",
          type: "application/pdf",
          disposition: "inline"
      end
    end
  end

  def edit
  end

  def update
    if @quote.update(quote_params)
      redirect_to admin_quote_path(@quote), notice: "문의 상태가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quote.destroy
    redirect_to admin_quotes_path, notice: "문의 내역이 삭제되었습니다.", status: :see_other
  end

  def bulk_destroy
    if params[:quote_ids].present?
      # Ensure scoped protection for bulk destroy
      target_quotes = Quote.where(id: params[:quote_ids])
      unless session[:admin_id] == "admin" || current_user&.super_admin?
        owned_agency_ids = Agency.where(owner_id: current_user.id).pluck(:id)
        managed_agency_ids = Agency.where("admin_ids LIKE ?", "%\"#{current_user.id}\"%").pluck(:id)
        target_quotes = target_quotes.where(agency_id: owned_agency_ids + managed_agency_ids)
      end
      
      target_quotes.destroy_all
      redirect_to admin_quotes_path, notice: "선택한 문의 내역이 삭제되었습니다.", status: :see_other
    else
      redirect_to admin_quotes_path, alert: "삭제할 항목을 선택해주세요.", status: :see_other
    end
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
    
    # Authorization Check
    unless session[:admin_id] == "admin" || current_user&.super_admin?
      owned_agency_ids = Agency.where(owner_id: current_user.id).pluck(:id)
      managed_agency_ids = Agency.where("admin_ids LIKE ?", "%\"#{current_user.id}\"%").pluck(:id)
      unless (owned_agency_ids + managed_agency_ids).include?(@quote.agency_id)
        redirect_to admin_quotes_path, alert: "해당 문의에 대한 권한이 없습니다."
      end
    end
  end

  def quote_params
    params.require(:quote).permit(:status, :workflow_status)
  end

  def generate_quote_pdf(quote)
    Prawn::Document.new do |pdf|
      # Windows Korean Font Support
      font_path = "C:/Windows/Fonts/malgun.ttf"
      if File.exist?(font_path)
        pdf.font font_path
      end

      pdf.text "견적 문의 상세 (Quote Detail)", size: 24, style: :bold, align: :center
      pdf.move_down 30

      # Meta Info
      pdf.text "접수 번호: ##{quote.id}", size: 12
      pdf.text "접수 일자: #{quote.created_at.strftime('%Y-%m-%d %H:%M')}", size: 12
      pdf.text "현재 상태: #{quote.status}", size: 12
      pdf.move_down 20

      pdf.stroke_horizontal_rule
      pdf.move_down 20

      # Client Info
      pdf.text "고객 정보", size: 16, style: :bold
      pdf.move_down 10
      
      client_data = [
        ["담당자명", quote.contact_name],
        ["회사명", quote.company_name || "-"],
        ["이메일", quote.email],
        ["연락처", quote.phone]
      ]
      
      pdf.table(client_data, width: pdf.bounds.width) do
        cells.padding = 8
        cells.borders = [:bottom]
        column(0).font_style = :bold
        column(0).width = 100
      end

      pdf.move_down 30

      # Project Info
      pdf.text "프로젝트 정보", size: 16, style: :bold
      pdf.move_down 10

      project_data = [
        ["프로젝트 유형", quote.project_type],
        ["예산", quote.budget]
      ]

      pdf.table(project_data, width: pdf.bounds.width) do
        cells.padding = 8
        cells.borders = [:bottom]
        column(0).font_style = :bold
        column(0).width = 100
      end

      pdf.move_down 30

      # Message
      pdf.text "문의 내용", size: 16, style: :bold
      pdf.move_down 10
      pdf.text quote.message, size: 11, leading: 4

      # Footer
      pdf.number_pages "Page <page> of <total>", at: [pdf.bounds.right - 150, 0], width: 150, align: :right, size: 10
    end
  end
end
