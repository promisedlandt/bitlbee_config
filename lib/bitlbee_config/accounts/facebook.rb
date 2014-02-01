module BitlbeeConfig
  module Accounts
    class Facebook < Accounts::Jabber
      attr_accessor :auth_strategy

      USERNAME_SUFFIX = "@chat.facebook.com"

      def initialize(options = {})
        # username needs to be downcased when not using OAuth. Just always downcase it, always works
        options[:handle] &&= options[:handle].downcase

        # unless otherwise specified, use oauth authentication
        @auth_strategy = options.delete(:auth_strategy) || :oauth

        options = add_auth_strategy_options(options)

        super({ tag: "fb",
                nick_format: "%full_name"
              }.merge(options))

        ensure_handle_is_suffixed if @handle
      end

      # We don't want the user to have to enter "@chat.facebook.com" with their handle, so we do it for them
      def ensure_handle_is_suffixed
        @handle += USERNAME_SUFFIX unless @handle =~ /#{ USERNAME_SUFFIX }$/
      end

      # Depending on the authentication strategy, we set a few things
      #
      # @param [Hash] init_options The options passed to initialize
      # @return [Hash] The original options, which may be modified now
      def add_auth_strategy_options(init_options)
        case @auth_strategy
        when :oauth
          init_options[:oauth] = "on"
          init_options[:cleartext_password] ||= ""
        end

        init_options
      end
    end
  end
end
