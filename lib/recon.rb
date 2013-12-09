require 'spidey'
require 'spidey-mongo'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/core_ext/class'

module Recon
  autoload :Crawler, 'recon/crawler'
  autoload :MongoStore, 'recon/mongo_store'
  autoload :Refill, 'recon/refill'
end
