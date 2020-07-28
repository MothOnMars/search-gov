class Admin::SearchgovDomainsController < Admin::AdminController
  active_scaffold :searchgov_domain do |config|
    config.label = 'Search.gov Domains'
    config.actions = %i[create list search export nested]
    config.create.columns = [:domain]
    config.columns = %i[
      id domain canonical_domain status activity
      urls_count unfetched_urls_count created_at
    ]
    config.nested.add_link(:searchgov_urls, label: "URLs", page: false)
    config.nested.add_link(:sitemaps, page: false)
    config.action_links.add 'reindex',
      label: 'Reindex',
      type: :member,
      crud_type: :update,
      method: :post,
      position: false,
      inline: true,
      confirm: 'Are you sure you want to reindex this entire domain?'
  end

  def after_create_save(record)
    flash[:info] = "#{record.domain} has been created. Sitemaps will automatically begin indexing."
  end

  def reindex
    process_action_link_action { |searchgov_domain| searchgov_domain.reindex }

    # TODO: flash?
  end
end
