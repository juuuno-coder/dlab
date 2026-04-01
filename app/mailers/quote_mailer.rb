class QuoteMailer < ApplicationMailer
  default from: 'noreply@dlab-website.com'

  def new_quote_notification(quote)
    @quote = quote
    @admin_email = ENV.fetch('ADMIN_EMAIL', 'juuuno@naver.com')
    
    mail(
      to: @admin_email,
      subject: "[DLAB] 새로운 견적 문의: #{quote.contact_name}님"
    )
  end

  def quote_confirmation(quote)
    @quote = quote
    
    mail(
      to: quote.email,
      subject: "[DLAB] 견적 문의가 접수되었습니다"
    )
  end
end
