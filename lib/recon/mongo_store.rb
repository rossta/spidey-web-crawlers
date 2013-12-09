module Recon
  module MongoStore
    def self.included(base)
      base.class_attribute :db

      base.send :include, Spidey::Strategies::Mongo
      base.extend ClassMethods

      base.db = ::Mongo::MongoClient.new.db
    end

    module ClassMethods

      def build(opts = {})
        new(default_options.merge(opts))
      end

      def default_options
        {
          url_collection: url_collection,
          result_collection: result_collection,
          error_collection: error_collection,
          request_interval: request_interval,
          verbose: true
        }
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
end
