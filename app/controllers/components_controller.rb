class ComponentsController < ApplicationController
  layout "admin" 

  def index
    # Dummy data for preview
    @instagram_feed_images = [
      "https://images.unsplash.com/photo-1515405295579-ba7f9f1b8cd8?q=80&w=400",
      "https://images.unsplash.com/photo-1545989253-02cc26577f88?q=80&w=400",
      "https://images.unsplash.com/photo-1547891654-e66ed7ebb968?q=80&w=400",
      "https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=400"
    ]
    
    @gallery_images = [
      "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?q=80&w=800",
      "https://images.unsplash.com/photo-1514525253440-b393452e3383?q=80&w=800",
      "https://images.unsplash.com/photo-1550614000-4b9519e49a2a?q=80&w=800",
      "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=800",
      "https://images.unsplash.com/photo-1516280440614-6697288d5d38?q=80&w=800",
      "https://images.unsplash.com/photo-1485546246426-74dc88dec4d9?q=80&w=800",
      "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=800",
      "https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?q=80&w=800",
      "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=800"
    ]
  end
end
