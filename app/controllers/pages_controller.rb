class PagesController < ApplicationController
  def home
    begin
      @featured_templates = DesignTemplate.all_combined.select(&:is_featured).take(3)
    rescue => e
      Rails.logger.error "Home featured templates error: #{e.message}"
      @featured_templates = []
    end
  end

  def portfolio
    begin
      @portfolios = Portfolio.order(created_at: :desc)
    rescue => e
      Rails.logger.error "Failed to load portfolios: #{e.message}"
      @portfolios = []
    end
  end

  def contact
    @quote = Quote.new
    
    # Static data fallback for template lookup
    if params[:template_id].present?
      @target_template = DesignTemplate.all_static.find { |t| t.id == params[:template_id].to_i }
      if @target_template
        @preview_url = @target_template.preview_url
        @preview_title = @target_template.title
      end
    end

    # 직접 URL 파라미터가 넘어오면 우선 적용 (안전 장치)
    if params[:preview_url].present?
      @preview_url = params[:preview_url]
    end
    
    # 템플릿 제목도 파라미터가 있다면 우선 적용
    if params[:template_title].present?
      @preview_title = params[:template_title]
    end
  end

  def pricing
  end

  def privacy
  end

  def terms
  end

  def debug_error
    begin
      count = DesignTemplate.count
      render plain: "Success! DesignTemplate count: #{count}"
    rescue => e
      render plain: "Error: #{e.class} - #{e.message}\n\nBacktrace:\n#{e.backtrace.join("\n")}", status: :internal_server_error
    end
  end

  def create_quote
    # Honeypot check: Bots will fill 'nickname' which is hidden from human users
    if params[:quote][:nickname].present?
      Rails.logger.warn "SPAM PREVENTED: Honeypot field filled by #{params[:quote][:email]}"
      flash[:notice] = "문의가 접수되었습니다." # Fake success message to not alert the bot
      return redirect_to contact_path
    end

    begin
      @quote = Quote.new(quote_params)
      @quote.agency = @current_agency if @current_agency
      @quote.status = "pending"
      @quote.created_at = Time.current # Ensure it has a timestamp for the mailer
      
      if user_signed_in?
        @quote.user = current_user
      else
        @quote.guest_session_id = cookies.signed[:guest_id]
      end

      if @quote.save
        # Normal path: DB is alive
        send_quote_emails(@quote)
        
        if user_signed_in?
          flash[:notice] = "문의가 성공적으로 접수되었습니다. 담당자가 확인 후 연락드리겠습니다."
        else
          flash[:notice] = "문의가 접수되었습니다. 회원가입을 하시면 상담 내역을 연동하여 확인하실 수 있습니다."
        end
        redirect_to contact_path
      else
        render :contact, status: :unprocessable_entity
      end
    rescue => e
      # Database connection error (e.g. Render DB expired)
      Rails.logger.error "CRITICAL: Inquiry DB write failed, fallback to email only: #{e.message}"
      
      # Mock the object for the mailer since DB save failed
      @fallback_quote = OpenStruct.new(quote_params)
      @fallback_quote.created_at = Time.current
      
      # Try to send email even if DB is down
      begin
        send_quote_emails(@fallback_quote)
        flash[:notice] = "문의가 접수되었습니다. (시스템 점검 중이나 메일로 정상 접수되었습니다.)"
      rescue => mail_e
        Rails.logger.error "Email delivery also failed: #{mail_e.message}"
        flash[:notice] = "문의가 접수되었습니다. (시스템 점검 중으로 확인 후 연락드리겠습니다.)"
      end
      
      redirect_to contact_path
    end
  end

  private

  def send_quote_emails(quote)
    QuoteMailer.new_quote_notification(quote).deliver_now
    QuoteMailer.quote_confirmation(quote).deliver_now
  end

  def robots
    robots_txt = <<~TEXT
      User-agent: *
      Allow: /
      Disallow: /admin
      Disallow: /templates/*
      Sitemap: #{request.base_url}/sitemap.xml
    TEXT
    render plain: robots_txt
  end

  def sitemap
    @base_url = request.base_url
    begin
      @templates = DesignTemplate.all_static
      @portfolios = [] # Database is down, no static data for portfolios yet
    rescue => e
      Rails.logger.error "Failed to load data for sitemap: #{e.message}"
      @templates = []
      @portfolios = []
    end
    
    render formats: :xml
  end

  private

  def quote_params
    params.require(:quote).permit(:contact_name, :company_name, :email, :phone, :project_type, :budget, :message, :preferred_domain, :nickname)
  end
end
