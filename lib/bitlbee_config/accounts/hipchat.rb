module BitlbeeConfig
  module Accounts
    class Hipchat < Accounts::Jabber
      USERNAME_SUFFIX = "@chat.hipchat.com"

      def initialize(options = {})
        super({ tag: "hipchat",
                nick_format: "%full_name"
              }.merge(options))

        ensure_handle_is_suffixed if @handle
      end

      # We don't want the user to have to enter "@chat.facebook.com" with their handle, so we do it for them
      def ensure_handle_is_suffixed
        @handle += USERNAME_SUFFIX unless @handle =~ /#{ USERNAME_SUFFIX }$/
      end
    end
  end
end
