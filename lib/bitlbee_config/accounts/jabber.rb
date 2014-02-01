module BitlbeeConfig
  module Accounts
    class Jabber < Account
      def initialize(options = {})
        @protocol = :jabber
        super
      end
    end
  end
end
