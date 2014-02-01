module BitlbeeConfig
  module Accounts
    class Icq < Account
      def initialize(options = {})
        @protocol = :oscar
        super
      end
    end
  end
end
