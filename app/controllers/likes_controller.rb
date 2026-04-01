class LikesController < ApplicationController
  before_action :authenticate_user!

  def toggle
    template = DesignTemplate.find(params[:design_template_id])
    like = current_user.likes.find_by(design_template: template)

    if like
      like.destroy
      @liked = false
    else
      current_user.likes.create(design_template: template)
      @liked = true
    end

    # Turbo Stream 응답으로 하트 아이콘만 부분 업데이트
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: design_templates_path) }
    end
  end
end
