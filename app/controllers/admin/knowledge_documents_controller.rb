class Admin::KnowledgeDocumentsController < ApplicationController
  before_action :set_knowledge_document, only: [:show, :edit, :update, :destroy, :analyze]

  def index
    @knowledge_documents = KnowledgeDocument
      .by_category(params[:category])
      .recent_first
      .page(params[:page])
      .per(20)

    @stats = {
      total: KnowledgeDocument.active.count,
      by_category: KnowledgeDocument.active.group(:category).count,
      analyzed: KnowledgeDocument.analyzed.count,
      pending: KnowledgeDocument.pending_analysis.count
    }
  end

  def show
  end

  def new
    @knowledge_document = KnowledgeDocument.new
  end

  def create
    @knowledge_document = KnowledgeDocument.new(knowledge_document_params)

    if @knowledge_document.save
      # 자동 분석 (백그라운드 처리 가능)
      if @knowledge_document.document.attached?
        @knowledge_document.analyze_with_gemini
      end

      redirect_to admin_knowledge_document_path(@knowledge_document), notice: '지식 베이스 문서가 등록되었습니다.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @knowledge_document.update(knowledge_document_params)
      redirect_to admin_knowledge_document_path(@knowledge_document), notice: '지식 베이스 문서가 수정되었습니다.'
    else
      render :edit
    end
  end

  def destroy
    @knowledge_document.destroy
    redirect_to admin_knowledge_documents_path, notice: '지식 베이스 문서가 삭제되었습니다.'
  end

  def analyze
    result = @knowledge_document.analyze_with_gemini

    if result[:success]
      redirect_to admin_knowledge_document_path(@knowledge_document), notice: '🤖 Gemini AI 분석이 완료되었습니다.'
    else
      redirect_to admin_knowledge_document_path(@knowledge_document), alert: "분석 실패: #{result[:error]}"
    end
  end

  private

  def set_knowledge_document
    @knowledge_document = KnowledgeDocument.find(params[:id])
  end

  def knowledge_document_params
    params.require(:knowledge_document).permit(:title, :category, :description, :document, :active)
  end
end
