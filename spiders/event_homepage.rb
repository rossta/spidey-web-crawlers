class EventHomepage < Recon::Crawler
  self.max_urls = 25

  handle "http://route66marathon.com/", :process_homepage

  def process_homepage(page, default_data = {})
    date = parse_date(page)

    puts date
  end

  def parse_date(page)

  end

end
