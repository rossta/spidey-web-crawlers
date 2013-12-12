%w[
  mobile_running_in_the_usa_com
  slowtwich_com
].each do |spider|
  God.watch do |w|
    w.name = spider
    w.start = "/data/apps/recon/current/script/crawl #{spider}"
    w.keepalive
  end
end
