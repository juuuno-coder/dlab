class DesignTemplatesController < ApplicationController
  def index
    begin
      # Load from Combined Data (Database + Static)
      @design_templates = DesignTemplate.all_combined

      # Search functionality (In-memory)
      if params[:query].present?
        query = params[:query].downcase
        @design_templates = @design_templates.select do |t|
          t.title.downcase.include?(query) || 
          t.description.downcase.include?(query) || 
          t.category.downcase.include?(query)
        end
      end

      # Category filter (In-memory)
      if params[:category].present? && params[:category] != 'all'
        @design_templates = @design_templates.select { |t| t.category == params[:category] }
      end

      # Sorting logic (In-memory)
      case params[:sort]
      when 'popular'
        # No actual view_count in static, fallback to featured first
        @design_templates = @design_templates.sort_by { |t| [t.is_featured ? 0 : 1, t.title] }
      when 'latest'
        @design_templates = @design_templates.reverse
      else # 'recommend' or default
        @design_templates = @design_templates.sort_by { |t| t.is_featured ? 0 : 1 }
      end

      # Pagination (Simple array slicing)
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      per_page = 12
      @design_templates = Kaminari.paginate_array(@design_templates).page(page).per(per_page)
      
    rescue => e
      Rails.logger.error "Static Template load failed: #{e.message}"
      @design_templates = []
    end
  end
end
