module BitlbeeConfig
  module Accounts
    class Gtalk < Accounts::Jabber
      DEFAULT_GTALK_SERVER = "talk.google.com"

      def initialize(options = {})
        # unlike facebook, we don't give support password authentication here, only oauth
        super({ tag: "gtalk",
                nick_format: "%full_name",
                server: DEFAULT_GTALK_SERVER,
                oauth: "on",
                cleartext_password: ""
              }.merge(options))
      end
    end
  end
end
