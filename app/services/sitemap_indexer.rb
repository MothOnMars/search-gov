# frozen_string_literal: true

class SitemapIndexer
  attr_reader :domain,
              :scheme,
              :searchgov_domain,
              :uri

  def initialize(sitemap_url:)
    @uri = URI(sitemap_url)
    @domain = uri.host
    @scheme = uri.scheme
    @searchgov_domain = SearchgovDomain.find_by(domain: domain)
  end

  def index
    sitemap_index? ? enqueue_sitemaps : process_entries
  end

  private

  def sitemaps_stream
    @sitemaps_stream ||= Saxerator.parser(sitemap).
                           within('sitemapindex').for_tag('sitemap')
  end

  def sitemap_index?
    sitemaps_stream.any?
  rescue Saxerator::ParseException
    # Rescue & move on, in case we can process any URLs before the parser barfs
    false
  end

  def sitemap_entries_stream
    @sitemap_entries_stream ||= Saxerator.parser(sitemap).
                                  within('urlset').for_tag('url')
  end

  def enqueue_sitemaps
    XmlSitemapIndexProcessor.new(xml: sitemap).process_entries
  end

  def process_entries
    XmlSitemapProcessor.new(sitemap_url: uri.to_s, xml: sitemap).process_entries
  end

  def log_info
    {
      time: Time.now.utc.to_formatted_s(:db),
      domain: domain,
      sitemap: uri.to_s
    }
  end

  def sitemap
    @sitemap ||= begin
      HTTP.headers(user_agent: DEFAULT_USER_AGENT).
        timeout(connect: 20, read: 60).follow.get(uri).to_s
    rescue => e
      error_info = log_info.merge(error: e.message)
      log_line = "[Searchgov SitemapIndexer] #{error_info.to_json}"
      Rails.logger.warn log_line.red
      ''
    end
  end

end
