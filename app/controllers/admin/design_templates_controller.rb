class Admin::DesignTemplatesController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_design_template, only: %i[ edit update destroy ]

  def index
    @design_templates = DesignTemplate.order(created_at: :desc)
  end

  def new
    @design_template = DesignTemplate.new
  end

  def create
    @design_template = DesignTemplate.new(design_template_params)

    if @design_template.save
      Rails.cache.delete("featured_templates")
      redirect_to admin_design_templates_path, notice: "템플릿이 성공적으로 등록되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @design_template.update(design_template_params)
      Rails.cache.delete("featured_templates")
      redirect_to admin_design_templates_path, notice: "템플릿이 성공적으로 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @design_template.destroy
    Rails.cache.delete("featured_templates")
    redirect_to admin_design_templates_path, notice: "템플릿이 삭제되었습니다."
  end

  private

  def set_design_template
    @design_template = DesignTemplate.find(params[:id])
  end

  def design_template_params
    params.require(:design_template).permit(
      :title, :description, :category, 
      :pc_image, :mobile_image, 
      :preview_url, :is_featured, 
      :image_url, :mobile_image_url
    )
  end

end
