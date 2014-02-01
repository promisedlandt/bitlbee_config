module BitlbeeConfig
  module Accounts
    class Steam < Account
      def initialize(options = {})
        @protocol = :steam
        @tag = "steam"
        super
      end
    end
  end
end
