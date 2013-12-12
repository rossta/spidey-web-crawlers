God.watch do |w|
  w.name = 'slowtwitch_com'
  w.start = "/data/apps/recon/current/script/crawl slowtwitch_com"
  w.keepalive
end

God.watch do |w|
  w.name = 'mobile_running_in_the_usa_com'
  w.start = "/data/apps/recon/current/script/crawl mobile_running_in_the_usa_com"
  w.keepalive
end
