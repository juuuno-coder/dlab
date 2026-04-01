class UpdateStayTemplateUrls < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    camp = DesignTemplate.find_by(title: "Camp Vibez")
    camp&.update(preview_url: "/templates/camping", category: "stay")

    focus = DesignTemplate.find_by(title: "Focus Lab")
    focus&.update(preview_url: "/templates/studio", category: "stay")
    
    # Ensure Medical/Law specific updates (though files were edited in place)
    # Just to be safe, if we changed titles slightly or want to categorize
    pure = DesignTemplate.find_by(title: "Pure Clinic")
    pure&.update(category: "medical")
    
    trust = DesignTemplate.find_by(title: "Trust & Logic")
    trust&.update(category: "law")
  end
end
