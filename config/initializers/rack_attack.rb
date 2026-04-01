class Rack::Attack
  # Rate limiting - Generic
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Prevent Brute-Force Login Attacks
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/admin/sessions' && req.post?
      req.ip
    end
  end

  # Spam Protection for Contact Form
  throttle('contact/ip', limit: 3, period: 1.minute) do |req|
    if req.path == '/contact' && req.post?
      req.ip
    end
  end

  # Block specific spam keywords in contact form
  class Request < ::Rack::Request
    def spam_content?
      return false unless path == '/contact' && post?
      
      # Check params safely
      message = params.dig('quote', 'message').to_s.downcase
      contact_name = params.dig('quote', 'contact_name').to_s.downcase
      
      # Spam keywords list
      spam_keywords = [
        'casino', 'viagra', 'cryptocurrency', 'bit.ly', 'crypto', 'investment', 
        'seo ranking', 'google result'
      ]
      
      # Check for keywords
      if spam_keywords.any? { |word| message.include?(word) || contact_name.include?(word) }
        return true
      end

      # Check for excessive links (more than 2 http/https links)
      if message.scan(/http[s]?:\/\//).count > 2
         return true
      end

      false
    end
  end

  blocklist('block_spam_content') do |req|
    req.spam_content?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    [
      429,
      { 'Content-Type' => 'text/html; charset=utf-8' }, # UTF-8 encoding added
      ['<html><body><h1>요청이 너무 많습니다</h1><p>잠시 후 다시 시도해 주세요.</p></body></html>']
    ]
  end
  
  # Custom response for blocked requests (Spam)
  self.blocklisted_responder = lambda do |request|
    [
      403,
      { 'Content-Type' => 'text/html; charset=utf-8' },
      ['<html><body><h1>접근이 거부되었습니다</h1><p>비정상적인 요청이 감지되었습니다.</p></body></html>']
    ]
  end
end
