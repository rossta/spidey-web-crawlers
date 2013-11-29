module Crawl
  class RunningusaCrawler < Spidey::AbstractSpider
    include Spidey::Strategies::Mongo

    def self.db
      @@db ||= Mongo::Connection.new['runningusa_crawler']
    end

    def self.crawl
      spider = new(
        url_collection: db['urls'],
        result_collection: db['results'],
        error_collection: db['errors'],
        verbose: true,
        request_interval: 5)

      spider.crawl max_urls: 500
    end

    handle "http://www.runningintheusa.com/Race/Default.aspx", :process_states

    def process_states(page, default_data = {})
      page.search("td.Caption a.StateLink").each do |a|
        Spidey.logger.info "Processing state: #{a['href']}"
        handle resolve_url(a['href'], page), :process_race_index
      end
    end

    def process_race_index(page, data = {})
      page.search(%Q[a[href*="View.aspx"]]).each do |a|
        Spidey.logger.info "Processing race_index: #{a['href']}"

        handle resolve_url(a['href'], page), :process_race_detail
      end
    end

    def process_race_detail(page, data = {})
      record data.merge \
        title: page.search(".ViewTitle").text.strip,
        race_date: page.search("td.ViewLabel:contains('Race Date') + td").text.gsub("&nbsp", "").gsub(/\s+/, " ").strip,
        city_state: page.search("td.ViewLabel:contains('City') + td").text.gsub(/\s+/, " ").strip,
        events: page.search("td.ViewLabel:contains('Events') + td").text.gsub(/\s+/, " ").strip,
        website: resolve_redirect_link(page.search("td.ViewLabel:contains('Race Website') + td").search("a")),
        registration: resolve_redirect_link(page.search("td.ViewLabel:contains('Registration') + td").search("a"))
    end

    private

    def resolve_redirect_link(anchors)
      return "" if anchors.empty?
      link = anchors.first['href']
      page = agent.get(link)
      page.instance_variable_get("@uri").to_s
    end
  end
end
