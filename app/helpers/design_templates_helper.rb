module DesignTemplatesHelper
  def template_price_tier(category)
    high_tier = %w[stay startup portfolio dining wine medical corporate finance consulting ecommerce hotel sculpt]
    mid_tier = %w[cafe barber gym yoga studio flower dessert salad vet dental pension study artistry]
    
    if high_tier.include?(category)
      70
    elsif mid_tier.include?(category)
      50
    else
      30
    end
  end
end
