class SlowtwitchCom < Recon::Crawler
  self.max_urls = 1000
  self.request_interval = 1

  include Recon::MongoStore

  handle 'http://calendar.slowtwitch.com/', :process_state_index

  def process_state_index(page, default_data = {})
    log "process_state_index: #{page.title}, #{page.uri}"
    links = page.search('.statenav a').map { |a| a['href'] }

    # link = links.first
    links.each do |link|
      handle resolve_url(link, page), :process_race_index
    end
  end

  def process_race_index(page, data = {})
    log "process_race_index: #{page.title}, #{page.uri}"
    links = page.search("#content a.sub-hdr").map { |a| a['href'] }

    # link = links.first
    links.each do |link|
      handle resolve_url(link, page), :process_race_detail
    end
  end

  def process_race_detail(page, data = {})
    log "process_race_detail: #{page.title}, #{page.uri}"
    title = StripString(page.search("#content h2").text)
    uid   = parse_page_query(page)['uid'] || title

    data = data.merge \
      race_id: uid,
      title: title,
      race_date: parse_text_after_node(page, 'Date:'),
      start_time: parse_text_after_node(page, 'Start:'),
      course: parse_text_after_node(page, 'Course:'),
      description: parse_text_after_node(page, 'Course Info:'),
      more_details: parse_text_after_node(page, 'More:'),
      surface: parse_text_after_node(page, 'Bike Surface:'),
      address: parse_text_after_node(page, 'Address:'),
      location: parse_text_after_node(page, 'Location:'),
      contact: parse_text_after_node(page, 'Contact:'),
      website: parse_link_after_node(page, 'Website:'),
      registration: parse_link_after_node(page, 'Register:')

    record data
  end

  def result_key(data)
    data[:race_id]
  end

  def parse_text_after_node(page, contains)
    match = page.search("#content .content div:contains('#{contains}')").to_html.match(regex_text_after_node(contains))
    StripString(match && match[1] || '')
  end

  def parse_link_after_node(page, contains)
    text = parse_text_after_node(page, contains)
    Nokogiri.parse(text).search("a").map { |a| a['href'] }
  end

  def regex_text_after_node(contains)
    /#{contains}\<[^\<]*\>(.+?(?=\<br\>))/
  end

end
