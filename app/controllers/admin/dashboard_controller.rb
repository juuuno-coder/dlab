class Admin::DashboardController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @portfolios_count = Portfolio.count
    @quotes_count = Quote.count
    @pending_quotes_count = Quote.where(status: "pending").count
    @templates_count = DesignTemplate.count
    @featured_templates_count = DesignTemplate.where(is_featured: true).count
    @users_count = User.count
    @orders_count = Order.count
    @pending_orders_count = Order.where(status: "pending").count
    
    @recent_portfolios = Portfolio.order(created_at: :desc).limit(5)
    @recent_quotes = Quote.order(created_at: :desc).limit(5)
    @recent_orders = Order.preload(:user).order(created_at: :desc).limit(5)
    
    # Monthly Stats (Last 6 months)
    @monthly_stats = (0..5).map do |i|
      date = i.months.ago
      start_date = date.beginning_of_month
      end_date = date.end_of_month
      {
        month: date.strftime("%-m월"),
        count: Quote.where(created_at: start_date..end_date).count
      }
    end.reverse
  end
end
