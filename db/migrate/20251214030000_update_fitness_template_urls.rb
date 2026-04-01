class UpdateFitnessTemplateUrls < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    sculpt = DesignTemplate.find_by(title: "Sculpt & Soul")
    if sculpt
      sculpt.update(preview_url: "/templates/sculpt")
      puts "Updated Sculpt & Soul URL"
    end
    
    yoga = DesignTemplate.find_by(title: "Yoga Flow")
    if yoga
      yoga.update(preview_url: "/templates/yoga")
      puts "Updated Yoga Flow URL"
    end
  end
end
