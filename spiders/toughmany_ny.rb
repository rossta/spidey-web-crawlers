class ToughmanNy < Recon::Crawler
  include Recon::ToughmanNy

  handle "http://toughmantri.com", :process_home

  def process_home(page, default_data = {})
  end

end
