require 'vizsla/version'
require 'vizsla/middleware'
require 'vizsla/subscribers'

module Vizsla
  class Core
    @subscribers = Subscribers.new
  end
end
