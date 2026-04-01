xml.instruct!
xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
  # Static Pages
  xml.url do
    xml.loc @base_url
    xml.changefreq "daily"
    xml.priority 1.0
  end

  xml.url do
    xml.loc "#{@base_url}/design_templates"
    xml.changefreq "weekly"
    xml.priority 0.8
  end

  xml.url do
    xml.loc "#{@base_url}/portfolio"
    xml.changefreq "weekly"
    xml.priority 0.8
  end
  
  xml.url do
    xml.loc "#{@base_url}/contact"
    xml.changefreq "monthly"
    xml.priority 0.5
  end

  # Dynamic Pages - Templates (Modal driven, but maybe linkable)
  # 사실 템플릿은 모달로 뜨거나 contact로 연결되지만, 개별 페이지가 생긴다면 추가

  # Dynamic Pages - Portfolios (No detail page yet, but preparing)
  # @portfolios.each do |portfolio|
  #   xml.url do
  #     xml.loc "#{@base_url}/portfolio/#{portfolio.id}"
  #     xml.lastmod portfolio.updated_at.strftime("%Y-%m-%d")
  #     xml.changefreq "monthly"
  #     xml.priority 0.6
  #   end
  # end
end
