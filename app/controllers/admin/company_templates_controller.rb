class Admin::CompanyTemplatesController < ApplicationController
  before_action :set_company_template, only: [:show, :edit, :update, :destroy, :toggle_active]
  layout 'admin'

  def index
    @company_templates = CompanyTemplate.all.ordered
    @template_types = CompanyTemplate.template_types
  end

  def show
  end

  def new
    @company_template = CompanyTemplate.new
  end

  def create
    @company_template = CompanyTemplate.new(company_template_params)

    if @company_template.save
      redirect_to admin_company_templates_path, notice: '회사 템플릿이 추가되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company_template.update(company_template_params)
      redirect_to admin_company_templates_path, notice: '회사 템플릿이 수정되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company_template.destroy
    redirect_to admin_company_templates_path, notice: '회사 템플릿이 삭제되었습니다.'
  end

  def toggle_active
    @company_template.update(active: !@company_template.active)
    redirect_to admin_company_templates_path, notice: "템플릿이 #{@company_template.active ? '활성화' : '비활성화'}되었습니다."
  end

  private

  def set_company_template
    @company_template = CompanyTemplate.find(params[:id])
  end

  def company_template_params
    params.require(:company_template).permit(
      :name, :template_type, :content, :html_content, :order, :active
    )
  end
end
