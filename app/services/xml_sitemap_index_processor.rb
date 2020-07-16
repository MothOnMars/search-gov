class XmlSitemapIndexProcessor
  attr_reader :domain,
              :scheme,
              :searchgov_domain,
              :uri,
              :xml

  def initialize(xml:)
    @xml = xml
  end

  def process_entries
    enqueue_sitemaps
  end

  def sitemaps_stream
    @sitemaps_stream ||= Saxerator.parser(xml).
                           within('sitemapindex').for_tag('sitemap')
  end

  def enqueue_sitemaps
    sitemaps_stream.each do |sitemap|
      SitemapIndexerJob.perform_later(sitemap_url: sitemap['loc'].to_s)
    end
  end
end
