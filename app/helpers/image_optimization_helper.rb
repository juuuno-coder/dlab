module ImageOptimizationHelper
  # Generate optimized image tag with lazy loading
  def optimized_image_tag(source, options = {})
    defaults = {
      loading: 'lazy',
      decoding: 'async'
    }
    
    # Add srcset for responsive images if local image
    if source.start_with?('/images/')
      # Add width/height hints for layout stability
      options[:width] ||= options.delete(:width)
      options[:height] ||= options.delete(:height)
    end
    
    image_tag(source, defaults.merge(options))
  end
  
  # Get optimized template thumbnail URL
  def template_thumbnail_url(template)
    if template.pc_image.attached?
      url_for(template.pc_image)
    elsif template.image_url.present?
      template.image_url
    else
      '/images/templates/portfolio_gallery.png'
    end
  end
  
  # Generate WebP source with fallback
  def picture_tag(source, options = {})
    webp_source = source.sub(/\.(png|jpg|jpeg)$/i, '.webp')
    
    content_tag :picture do
      concat tag(:source, srcset: webp_source, type: 'image/webp')
      concat optimized_image_tag(source, options)
    end
  end
end
