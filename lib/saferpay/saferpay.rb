Dir[File.dirname(__FILE__) + '/saferpay/*.rb'].each do |file|
  require file
end

module Saferpay
  extend Configuration

end
