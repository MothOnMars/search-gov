require 'spec_helper'

describe DateRangeTopNQuery do
  let(:query) do
    DateRangeTopNQuery.new('affiliate_name',
                           Date.parse('2019-11-01'),
                           Date.parse('2019-11-07'),
                           'search',
                           { field: 'params.query.raw',
                             size: 1000 }
                          )
  end
  let(:expected_body) do
    {
      "query": {
        "bool": {
          "filter": [
            {
              "term": {
                "params.affiliate": "affiliate_name"
              }
            },
            {
              "term": {
                "type": "search"
              }
            },
            {
              "range": {
                "@timestamp": {
                  "gte": "2019-11-01",
                  "lte": "2019-11-07"
                }
              }
            }
          ],
          "must_not": {
            "term": {
              "useragent.device": "Spider"
            }
          }
        }
      },
      "aggs": {
        "agg": {
          "terms": {
            "field": "params.query.raw",
            "size": 1000
          }
        }
      }
    }.to_json
  end

  it_behaves_like 'a logstash query'
end
