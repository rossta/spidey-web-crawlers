class RunningUsaOrg < Recon::Crawler
  self.max_urls = 100

  handle "http://www.runningusa.org/events", :process_list_page

  URL_MATCH = /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/

  def process_list_page(page, default_data = {})
    page.search("#eventcalendarList .list .item").each do |item|
      record default_data.merge(ListItem.new(item).to_hash)
    end

    a = page.search(".pagination .next").first
    handle resolve_url(a["href"], page), :process_list_page if a
  end

  class ListItem < SimpleDelegator
    def title
      search("h2.title").text.strip
    end

    def date
      DateTime.parse(search(".dateWpr").text.strip).to_s
    end

    def location
      search(".locationWpr").text.strip.gsub(%r{^Location:\s+}, "")
    end

    def website
      website_match && website_match[0]
    end

    def to_hash
      { title: title, date: date, location: location, website: website }
    end

    private

    def website_match
      search(".urlWpr").text.match(URL_MATCH)
    end
  end
end
