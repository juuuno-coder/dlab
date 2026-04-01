class TemplatesController < ApplicationController
  # 템플릿 페이지는 기존 사이트의 헤더/푸터를 쓰지 않고 독립적인 디자인을 가집니다.
  layout "template_preview"

  # All templates in a list for reference
  VALID_TEMPLATES = %w[
    beauty dining gym study stay corporate ecommerce cafe portfolio 
    medical law wedding cleaning agency consulting academy sculpt yoga 
    nail barber flower burger wine salad dessert donut kinder startup 
    rental finance dental vet tax accounting camping studio petshop hotel pension 
    cloth shoe bag shopping learnhub english artistry artpage bizon
    oluolu_franchise oluolu_marketing kkang mz tech
  ]

  # Theme Data Loaded from Extraction (Advanced)
  THEMES = {
    "academy" => { "primary_color" => "#1B4332", "font_family" => "serif", "radius" => "rounded-lg" },
    "accounting" => { "primary_color" => "#005BAC", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "agency" => { "primary_color" => "#BEF264", "bg_color" => "#050505", "text_color" => "#ffffff", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "artistry" => { "primary_color" => "#333333", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "artpage" => { "primary_color" => "#000000", "bg_color" => "#ffffff", "text_color" => "#000000", "font_family" => "sans-serif", "radius" => "rounded-none" },
    "bag" => { "primary_color" => "#2D1B15", "font_family" => "sans-serif", "radius" => "rounded-none" },
    "barber" => { "primary_color" => "#B8860B", "bg_color" => "#121212", "text_color" => "#ffffff", "font_family" => "serif", "radius" => "rounded-none" },
    "beauty" => { "primary_color" => "#CFB997", "font_family" => "serif", "radius" => "rounded-lg" },
    "burger" => { "primary_color" => "#E8482D", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "cafe" => { "primary_color" => "#8B735B", "font_family" => "serif", "radius" => "rounded-lg" },
    "camping" => { "primary_color" => "#FF4500", "font_family" => "serif", "radius" => "rounded-none" },
    "cleaning" => { "primary_color" => "#2563EB", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "cloth" => { "primary_color" => "#57534E", "font_family" => "serif", "radius" => "rounded-lg" },
    "consulting" => { "primary_color" => "#111827", "font_family" => "serif", "radius" => "rounded-none" },
    "corporate" => { "primary_color" => "#0F172A", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "dental" => { "primary_color" => "#0D9488", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "dessert" => { "primary_color" => "#E6A4B4", "font_family" => "serif", "radius" => "rounded-md" },
    "dining" => { "primary_color" => "#BE123C", "bg_color" => "#18181B", "text_color" => "#ffffff", "font_family" => "serif", "radius" => "rounded-none" },
    "donut" => { "primary_color" => "#FF61A6", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "ecommerce" => { "primary_color" => "#333333", "font_family" => "serif", "radius" => "rounded-lg" },
    "english" => { "primary_color" => "#333333", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "finance" => { "primary_color" => "#333333", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "flower" => { "primary_color" => "#F472B6", "font_family" => "serif", "radius" => "rounded-lg" },
    "gym" => { "primary_color" => "#EAB308", "bg_color" => "#18181B", "text_color" => "#ffffff", "font_family" => "sans-serif", "radius" => "rounded-md" },
    "hotel" => { "primary_color" => "#BFA183", "font_family" => "serif", "radius" => "rounded-none" },
    "kinder" => { "primary_color" => "#FF6B6B", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "law" => { "primary_color" => "#2C3E50", "font_family" => "serif", "radius" => "rounded-lg" },
    "learnhub" => { "primary_color" => "#6366F1", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "medical" => { "primary_color" => "#0ea5e9", "font_family" => "serif", "radius" => "rounded-lg" },
    "nail" => { "primary_color" => "#FF00FF", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "pension" => { "primary_color" => "#786C5E", "font_family" => "sans-serif", "radius" => "rounded-md" },
    "petshop" => { "primary_color" => "#F97316", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "portfolio" => { "primary_color" => "#CCFF00", "bg_color" => "#000000", "text_color" => "#ffffff", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "rental" => { "primary_color" => "#333333", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "salad" => { "primary_color" => "#166534", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "sculpt" => { "primary_color" => "#D4A373", "bg_color" => "#1A1A1A", "text_color" => "#ffffff", "font_family" => "serif", "radius" => "rounded-lg" },
    "shoe" => { "primary_color" => "#CCFF00", "bg_color" => "#050505", "text_color" => "#ffffff", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "shopping" => { "primary_color" => "#333333", "font_family" => "serif", "radius" => "rounded-lg" },
    "startup" => { "primary_color" => "#6366F1", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "stay" => { "primary_color" => "#1A1A1A", "font_family" => "serif", "radius" => "rounded-none" },
    "studio" => { "primary_color" => "#737373", "font_family" => "sans-serif", "radius" => "rounded-md" },
    "study" => { "primary_color" => "#4A5D44", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "tax" => { "primary_color" => "#1e3a8a", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "vet" => { "primary_color" => "#1E3A8A", "font_family" => "sans-serif", "radius" => "rounded-lg" },
    "wedding" => { "primary_color" => "#8C7B6C", "font_family" => "serif", "radius" => "rounded-md" },
    "wine" => { "primary_color" => "#E0C097", "bg_color" => "#1a1a1a", "text_color" => "#ffffff", "font_family" => "serif", "radius" => "rounded-lg" },
    "yoga" => { "primary_color" => "#8B9178", "font_family" => "serif", "radius" => "rounded-lg" }
  }

  def show
    template_name = params[:template_name]
    if VALID_TEMPLATES.include?(template_name)
      if template_exists?(template_name)
        # Set theme data for the main template view as well
        @theme = get_theme_data(template_name)
        render template_name
      else
        render template_name
      end
    else
      redirect_to design_templates_path, alert: "템플릿을 찾을 수 없습니다."
    end
  rescue ActionView::MissingTemplate
    redirect_to design_templates_path, alert: "템플릿을 찾을 수 없습니다."
  end

  def sub_page
    template_name = params[:template_name]
    sub_page = params[:sub_page]

    specific_template = "#{template_name}_#{sub_page}"

    if template_exists?(specific_template)
      @theme = get_theme_data(template_name) # Ensure theme is available for specific subpages too if needed
      render specific_template
    else
      @template_name = template_name
      @sub_page_title = sub_page.humanize.titleize
      @theme = get_theme_data(template_name)
      render "templates/shared/generic_subpage"
    end
  end

  private

  def template_exists?(name)
    lookup_context.template_exists?(name, "templates", false)
  end

  def get_theme_data(template_name)
    # Default theme
    theme = {
      "primary_color" => "#333333",
      "bg_color" => "#ffffff",
      "text_color" => "#1f2937",
      "font_family" => "sans-serif",
      "radius" => "rounded-lg"
    }

    if THEMES.key?(template_name)
      theme.merge!(THEMES[template_name])
    end

    # Ensure bg_color and text_color exist if not provided
    theme["bg_color"] ||= "#ffffff"
    theme["text_color"] ||= "#1f2937"
    theme["radius"] ||= "rounded-lg"

    # Normalize font-family for Tailwind/CSS
    if theme["font_family"] == "serif"
      theme["font_css"] = "'Noto Serif KR', serif"
    else
      theme["font_css"] = "'Pretendard', sans-serif"
    end

    theme
  end
end
