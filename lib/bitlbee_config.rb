# Shipped with Ruby
# Specified in Gemfile
require "nokogiri"
require "mixlib/shellout"

# Internal stuff
require "bitlbee_config/core_extensions"
require "bitlbee_config/mixins"
require "bitlbee_config/version"
require "bitlbee_config/config"
require "bitlbee_config/account"
require "bitlbee_config/accounts"
require "bitlbee_config/channel"
require "bitlbee_config/user"

# rubocop:disable HandleExceptions
# Development stuff, can't be loaded in production, but that's fine
%w(debugger).each do |development_gem|
  begin
    require development_gem
  rescue LoadError
  end
end
# rubocop:enable HandleExceptions

# @author Nils Landt
module BitlbeeConfig
end
