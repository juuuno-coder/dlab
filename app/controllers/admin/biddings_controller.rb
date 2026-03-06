class Admin::BiddingsController < ApplicationController
  before_action :set_bidding, only: [:show, :edit, :update, :destroy, :generate_proposal, :generate_diagnosis, :generate_slides, :analyze_with_gemini, :generate_presentation_script]
  layout 'admin'

  def index
    @biddings = Bidding.all
    @biddings = @biddings.by_status(params[:status]) if params[:status].present?
    @biddings = @biddings.by_deadline

    # Stats
    @stats = {
      total: Bidding.count,
      scheduled: Bidding.where(status: "예정").count,
      in_progress: Bidding.where(status: "진행중").count,
      submitted: Bidding.where(status: "제출완료").count,
      selected: Bidding.where(status: "선정").count
    }
  end

  def show
  end

  def new
    @bidding = Bidding.new
  end

  def create
    @bidding = Bidding.new(bidding_params)

    if @bidding.save
      redirect_to admin_biddings_path, notice: '입찰사업이 추가되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @bidding.update(bidding_params)
      redirect_to admin_bidding_path(@bidding), notice: '입찰사업이 수정되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bidding.destroy
    redirect_to admin_biddings_path, notice: '입찰사업이 삭제되었습니다.'
  end

  def generate_proposal
    @bidding.generate_proposal_outline
    redirect_to admin_bidding_path(@bidding), notice: '제안서 아웃라인이 생성되었습니다.'
  end

  def generate_diagnosis
    @bidding.generate_diagnosis
    redirect_to admin_bidding_path(@bidding), notice: 'NotebookLM 스타일 진단 보고서가 생성되었습니다.'
  end

  def generate_slides
    @bidding.generate_slides_html
    redirect_to admin_bidding_path(@bidding), notice: '피그마 연동 가능한 슬라이드가 생성되었습니다.'
  end

  def analyze_with_gemini
    service = RfpAnalyzerService.new(@bidding)

    # 이미지가 첨부되어 있으면 이미지 분석, 없으면 텍스트 분석
    result = if @bidding.documents.attached?
               service.analyze_with_images
             else
               service.analyze
             end

    if result[:success]
      redirect_to admin_bidding_path(@bidding), notice: '🤖 Gemini AI 분석이 완료되었습니다. 분석 노트와 차별화 전략이 자동 생성되었습니다.'
    else
      redirect_to admin_bidding_path(@bidding), alert: "분석 중 오류가 발생했습니다: #{result[:error]}"
    end
  end

  def generate_presentation_script
    begin
      generator = PresentationScriptGenerator.new(@bidding)
      script = generator.generate

      @bidding.update!(presentation_script: script)

      redirect_to admin_bidding_path(@bidding), notice: '📝 발표대본이 생성되었습니다.'
    rescue => e
      redirect_to admin_bidding_path(@bidding), alert: "발표대본 생성 실패: #{e.message}"
    end
  end

  private

  def set_bidding
    @bidding = Bidding.find(params[:id])
  end

  def bidding_params
    params.require(:bidding).permit(
      :title, :agency, :application_period, :budget, :status,
      :progress, :assignee, :description, :deadline, :partner,
      :analysis_notes, :proposal_outline, :winning_strategy,
      :diagnosis_report, :slides_html,
      :slide_theme_color, :slide_font_family,
      :presentation_script, :proposal_content, :rfp_content, :task_order_content,
      documents: [], selected_template_ids: []
    )
  end
end
