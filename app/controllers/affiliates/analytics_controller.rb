class Affiliates::AnalyticsController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate
  before_filter :establish_aws_connection, :only => [:index, :monthly_reports]

  def index
    @title = "Query Logs - "
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @available_dates = DailyQueryStat.available_dates_range(@affiliate.name)
    @end_date = request["end_date"].blank? ? DailyQueryStat.most_recent_populated_date(@affiliate.name) : request["end_date"].to_date
    @start_date = request["start_date"].blank? ? @end_date : request["start_date"].to_date
    @popular_terms = DailyQueryStat.most_popular_terms(@affiliate.name, @start_date, @end_date, @num_results_dqs)
    @popular_noresults_terms = DailyQueryNoresultsStat.most_popular_no_results_queries(@start_date, @end_date, @num_results_dqs, @affiliate.name)
  end

  def left_nav_usage
    @title = "Page Views - "
    @available_dates = DailyLeftNavStat.available_dates_range(@affiliate.name)
    @end_date = request["end_date"].blank? ? DailyLeftNavStat.most_recent_populated_date(@affiliate.name) : request["end_date"].to_date
    @start_date = request["start_date"].blank? ? @end_date : request["start_date"].to_date
    @json = DailyLeftNavStat.collect_to_json(@affiliate, @start_date, @end_date)
  end

  def query_clicks
    @title = "Clicked URLs by Query - "
    @end_date = request["end_date"].to_date
    @start_date =  request["start_date"].to_date
    @query = request["query"]
    @top_urls = QueriesClicksStat.top_urls(@affiliate.name, @query, @start_date, @end_date)
  end

  def click_queries
    @title = "Queries leading to Clicked URL - "
    @end_date = request["end_date"].to_date
    @start_date =  request["start_date"].to_date
    @url = request["url"]
    @top_queries = QueriesClicksStat.top_queries(@affiliate.name, @url, @start_date, @end_date)
  end

  def top_urls
    @title = "Top Clicked URLs - "
    @num_results_dcs = (request["num_results_dcs"] || "10").to_i
    @available_dates = DailyClickStat.available_dates_range(@affiliate.name)
    @end_date = request["end_date"].blank? ? DailyClickStat.most_recent_populated_date(@affiliate.name) : request["end_date"].to_date
    @start_date = request["start_date"].blank? ? @end_date : request["start_date"].to_date
    @top_urls = DailyClickStat.top_urls(@affiliate.name, @start_date, @end_date, @num_results_dcs)
  end

  def trending_queries
    @title = "Today's Trending Queries - "
    @trending_queries = DailyQueryStat.trending_queries(@affiliate.name)
  end

  def monthly_reports
    @title = "Monthly Reports - "
    @most_recent_date = DailyUsageStat.most_recent_populated_date(@affiliate.name) || Date.current
    @report_date = params[:date].blank? ? Date.yesterday : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month, @affiliate.name)
    @total_clicks = DailySearchModuleStat.where(:day => @report_date.beginning_of_month..@report_date.end_of_month, :affiliate_name=> @affiliate.name).sum(:clicks)
  end

  def query_search
    @title = "Query Search - "
    @search_query_term = params["query"]
    @start_date = Date.parse(params["analytics_search_start_date"]) rescue 1.month.ago.to_date
    @end_date = Date.parse(params["analytics_search_end_date"]) rescue Date.yesterday
    @search_results = DailyQueryStat.query_counts_for_terms_like(@search_query_term, @affiliate.name, @start_date, @end_date)
  end
end
