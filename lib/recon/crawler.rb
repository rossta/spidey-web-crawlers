module Recon
  class Crawler < Spidey::AbstractSpider
    class_attribute :namespace
    class_attribute :max_urls
    class_attribute :request_interval

    self.max_urls = 1_000
    self.request_interval = 1

    def self.inherited(base)
      base.namespace = base.name.underscore
      super
    end

    def self.build(opts = {})
      new(opts)
    end

    def self.crawl(opts = {})
      spider = build(opts)
      spider.crawl max_urls: max_urls
    end

    def log(*args)
      Spidey.logger.info(*args)
    end

  end
end
