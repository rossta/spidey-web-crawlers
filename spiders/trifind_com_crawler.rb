class TrifindComCrawler < Recon::Crawler
  self.max_urls = 10_000

  handle "http://trifind.com", :process_home

  def process_home(page, default_data = {})
    page.search(".footer_links_columns a").each do |a|
      handle resolve_url(a['href'], page), :process_racelist,
        state: a.text.gsub(/(.*) Triathlons/, '\1'),
        num: 1
    end
  end

  def process_racelist(page, data = {})  # {:state=>"Alaska Triathlons"}
    Spidey.logger.info  "Race list: #{data.inspect}"
    num = data[:num]
    page.search(".racelist a.biglink").each do |a|
      handle resolve_url(a['href'], page), :process_racepage,
        title: a.text,
        uid: a['href'][%r{\d+}]
    end

    # pagination
    page.search("a.button[title='Next']").each do |a|
      next_num = num + 1
      Spidey.logger.info  "Next page:#{next_num}"
      handle resolve_url("/?page=#{next_num}", page), :process_racelist,
        data.merge(num: next_num)
    end
  end

  def process_racepage(page, data = {})
    Spidey.logger.info  "Race page: #{data.inspect}"
    events = [].tap do |list|
      page.search(".raceeventheader").each_with_index do |td, i|
        list << {
          title: td.text.strip,
          description: page.search(".raceevent")[i].text.strip
        }
      end
    end
    results = [].tap do |list|
      page.search("th:contains('Results') + td li").each do |li|
        list << {
          title: li.text.strip,
          link: li.search("a").map { |a| a['href'] }.first
        }
      end
    end

    city, state, zip = racepage_table_cell_text(page, 'City/State/Zip').split(/\s+/)
    record data.merge \
      events: events,
      results: results,
      race_date: racepage_table_cell_text(page,'Race Date'),
      start_time: racepage_table_cell_text(page, 'Start Time'),
      entry_fee: racepage_table_cell_text(page, 'Entry Fee'),
      location: racepage_table_cell_text(page, 'Location'),
      address: racepage_table_cell_text(page, 'Address'),
      city: city,
      state: state,
      zip: zip,
      country: racepage_table_cell_text(page, 'Country'),
      phone: racepage_table_cell_text(page, 'Phone'),
      email: racepage_table_cell_text(page, 'E-Mail'),
      usat_sanctioned: racepage_table_cell_text(page, 'USAT'),
      link: racepage_table_cell_href(page, 'Race Website'),
      description: racepage_table_cell_html(page, 'Description'),
      course_info: racepage_table_cell_html(page, 'Course Info'),
      directions: racepage_table_cell_html(page, 'Directions')
  end

  def racepage_table_cell_data(page, header)
    page.search("th:contains('#{header}') + td")
  end

  def racepage_table_cell_text(page, header)
    racepage_table_cell_data(page, header).text.strip
  end

  def racepage_table_cell_html(page, header)
    racepage_table_cell_data(page, header).to_html.gsub(/\s+/, " ").squeeze.strip
  end

  def racepage_table_cell_href(page, header)
    racepage_table_cell_data(page, header).css('a').attr('href').value
  end

  def result_key(data)
    data[:uid]
  end
end
