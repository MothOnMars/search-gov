class SearchImpression
  IRRELEVANT_KEYS = %w(access_key action api_key controller cx m utf8)

  def self.log(search, vertical, params, request)
    url = get_url_from_request(request)

    request_pairs = {
      clientip: request.remote_ip,
      request: url,
      referrer: request.referer,
      user_agent: request.user_agent
    }

    request_pairs[:diagnostics] = flatten_diagnostics_hash(search.diagnostics)
    relevant_params = params.reject { |k, v| IRRELEVANT_KEYS.include?(k.to_s) || k.to_s.include?('.') }
    hash = request_pairs.merge(time: Time.now.to_formatted_s(:db),
                               vertical: vertical,
                               modules: search.modules.join('|'),
                               params: relevant_params)

    Rails.logger.info("[Search Impression] #{hash.to_json}")
  end

  def self.get_url_from_request(request)
    if ! request.headers['X-Original-Request'].to_s.empty?
      Rails.logger.info("[X-Original-Request] (#{request.headers['X-Original-Request'].inspect})")
      request.headers['X-Original-Request']
    else
      request.url
      # "http://localhost:3000/search?utf8=%E2%9C%93&affiliate=logstash_testing&query=testing"
    end
  end

  def self.flatten_diagnostics_hash(diagnostics_hash)
    diagnostics_hash.keys.sort.map { |k| diagnostics_hash[k].merge(module: k) }
  end
end

=begin
{
     "clientip" => "::1",
      "request" => "http://localhost:3000/search?utf8=%E2%9C%93&affiliate=logstash_testing&query=test",
     "referrer" => "http://localhost:3000/search?affiliate=logstash_testing",
   "user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36",
  "diagnostics" => [
    {
              "result_count" => 0,
                "from_cache" => "none",
               "retry_count" => 0,
           "elapsed_time_ms" => 185,
      "tracking_information" => nil,
                    "module" => "BWEB"
    }
  ],
         "time" => "2020-08-24 10:54:11",
     "vertical" => "web",
      "modules" => "BOOS",
       "params" => {
    "affiliate" => "logstash_testing",
        "query" => "test"
  }
}
=end
