module BitlbeeConfig
  # A BitlBee user account - has channels for control / chat, and accounts with various IM services
  class User
    include BitlbeeConfig::XmlBuildable

    attr_accessor :nick, :password, :cleartext_password, :version, :settings, :accounts, :channels

    class << self
      # Rubocop thinks this method is too long, but I think it's more readable than split up
      # rubocop:disable MethodLength
      #
      # @param [Nokogiri::XML::Element] xml XML element to create user from
      # @return [BitlbeeConfig::User] The newly created user
      def from_xml(xml)
        new_user = {}

        %w(nick password version).each do |att|
          new_user[att.to_sym] = xml.attributes[att].value
        end

        xml.xpath("setting").each do |setting|
          new_user[setting.attributes["name"].value] = setting.text
        end

        new_user[:channels] = xml.xpath("channel").collect do |item|
          BitlbeeConfig::Channel.from_xml(item)
        end

        new_user[:accounts] = xml.xpath("account").collect do |item|
          BitlbeeConfig::Account.from_xml(item)
        end

        user = BitlbeeConfig::User.new(new_user)

        user.accounts.each do |account|
          account.user = user
        end

        user
      end
      # rubocop:enable MethodLength

      # XML configuration files are currently saved with the downcased username and an xml extension
      #
      # @param [String] username Username to turn into file name
      # @return [String] The file name of the this user's configuration file
      def username_to_filename(username)
        "#{ username.downcase }.xml"
      end
    end

    # @param [Hash] options
    # @option options [String] :nick Nickname for the user, as it appears in the IRC channel
    # @option options [String] :password The hashed password of the user, as it appears in the XML document
    # @option options [String] :cleartext_password Cleartext password for the user, will be hashed before saving to XML
    # @option options [String] :version I have no idea what this does
    # @option options [Array<BitlbeeConfig::Channel>] :channels Channels for this user
    # @option options [Array<BitlbeeConfig::Account|BitlbeeConfig::Accounts::Icq>] :accounts IM accounts for this user
    # @option options [String] All other entries will be converted to settings
    def initialize(options = {})
      @nick = options.delete(:nick)
      @password = options.delete(:password)
      @cleartext_password = options.delete(:cleartext_password)
      @version = options.delete(:version) || "1"
      @channels = options.delete(:channels) || []
      @accounts = options.delete(:accounts) || []

      @settings = options || {}
    end

    # Add an account. If an account with the same id already exists, it will be replaced
    #
    # @param [BitlbeeConfig::Account|BitlbeeConfig::Accounts::Icq] new_account Account to be added
    def add_or_replace_account(new_account)
      @accounts.reject! { |account| account.id == new_account.id }

      new_account.user = self
      @accounts << new_account
    end

    # Remove an account by its id
    #
    # @param [String] id_to_remove The account with this ID will be removed
    def remove_account_by_id(id_to_remove)
      @accounts.reject! { |account| account.id == id_to_remove }
    end

    # Remove an account
    #
    # @param [BitlbeeConfig::Account|BitlbeeConfig::Accounts::Icq] account_to_remove Account to remove
    def remove_account(account_to_remove)
      remove_account_by_id(account_to_remove.id)
    end

    # If a cleartext password is given, hash it and set password attribute
    def regenerate_password_if_needed
      @password = @cleartext_password.to_bitlbee_password_hash if @cleartext_password
    end

    # @param [Nokogiri::XML::Builder] xml_builder All XML will be added to this builder
    def build_xml(xml_builder)
      regenerate_password_if_needed

      to_xml_with_options(xml_builder, nick: @nick, password: @password, version: @version) do |user_xml|
        @accounts.each do |account|
          account.build_xml(user_xml)
        end

        @channels.each do |channel|
          channel.build_xml(user_xml)
        end
      end
    end
  end
end
