module Recon
  class Refill
    attr_accessor :namespace # to match complementary crawler

    include Recon::MongoStore

    def initialize(namespace)
      @namespace = namespace.to_s
    end

    def refill_urls
      while error = get_next_error
        add_url(error['spider'], error['url'], error['handler'])
        error_collection.remove('_id' => error['_id'])
      end
    end
    # error attributes
    # url, handler, error, created_at, error, message, spider

    def add_url(spider, url, handler, default_data = {})
      puts "Refilling #{spider}##{handler}: #{url}"
      url_collection.update(
        {'spider' => spider, 'url' => url},
        {'$set' => {'handler' => handler, 'default_data' => default_data}},
        upsert: true
      )
    end

    def get_next_error
      error_collection.find_one({}, {
        sort: [[:last_crawled_at, ::Mongo::ASCENDING], [:_id, ::Mongo::ASCENDING]]
      })
    end

    def url_collection
      db[namespace]['urls']
    end

    def result_collection
      db[namespace]['results']
    end

    def error_collection
      db[namespace]['errors']
    end

  end
end
