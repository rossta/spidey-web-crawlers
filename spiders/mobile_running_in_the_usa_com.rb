class MobileRunningInTheUsaCom < Recon::Crawler
  self.max_urls = 50_000
  self.request_interval = 5

  include Recon::MongoStore

  handle "http://m.runningintheusa.com/", :process_state_index

  def process_state_index(page, default_data = {})
    page.search(".PageLink a").each do |a|
      log "process_state_index: resolve #{a['href']}"
      handle resolve_url(a['href'], page), :process_month_index
    end
  end

  def process_month_index(page, data = {})
    page.search("#ctl00_ContentPlaceHolder1_panMonth .PageLink a").each do |a|
      log "process_month_index: resolve #{a['href']}"
      handle resolve_url(a['href'], page), :process_race_index
    end
  end

  def process_race_index(page, data = {})
    page.search("#ctl00_ContentPlaceHolder1_panList .PageLink a").each do |a|
      log "process_race_index: resolve #{a['href']}"
      handle resolve_url(a['href'], page), :process_race_detail
    end
  end

  def process_race_detail(page, data = {})
    title = StripString(page.search(".ViewTitle").text)
    uid   = parse_page_query(page)['RaceID'] || title

    data = data.merge \
      race_id: uid,
      title: title,
      race_date: StripString(page.search("td.ViewLabel:contains('Race Date') + td").text),
      city_state: StripString(page.search("td.ViewLabel:contains('City') + td").text),
      events: StripString(page.search("td.ViewLabel:contains('Events') + td").text),
      website: resolve_redirect_links(page.search("td.ViewLabel:contains('Race Website') + td").search("a")),
      registration: resolve_redirect_links(page.search("td.ViewLabel:contains('Registration') + td").search("a"))

    if include_results?
      data = data.merge results: resolve_redirect_links(page.search("#ctl00_ContentPlaceHolder1_trPastResults a"))
    end

    record data
  end

  private

  def result_key(data)
    data[:race_id]
  end

  def resolve_redirect_links(anchors)
    anchors = Array(anchors).compact
    return [] if anchors.empty?
    anchors.map do |a|
      page = agent.get(a['href'])
      page.instance_variable_get("@uri").to_s
    end.reject(&:blank?)
  end

  def StripString(string)
    string.to_s.gsub("&nbsp", ' ').gsub(/(\s|\t|\r|\n)+/, " ").strip
  end

  def include_results?
    false
  end

  def parse_page_query(page)
    Rack::Utils.parse_nested_query(page.uri.query) || {}
  end
end
