module BitlbeeConfig
  # An account with an IM service, e.g. an ICQ or Skype account
  class Account
    include BitlbeeConfig::XmlBuildable

    attr_accessor :protocol, :handle, :password, :autoconnect, :tag, :server, :cleartext_password, :user, :settings

    class << self
      # @param [Nokogiri::XML::Element] xml XML element to create account from
      # @return [BitlbeeConfig::Account|BitlbeeConfig::Accounts::Icq] The newly created account
      def from_xml(xml)
        new_account = {}

        # get setting attributes
        xml.attributes.each do |att_name, att_value|
          new_account[att_name.to_sym] = att_value.text
        end

        # get setting children
        xml.children.select { |node| node.is_a?(Nokogiri::XML::Element) }.each do |setting_element|
          new_account[setting_element.values.first.to_sym] = setting_element.text
        end

        create_new_account(new_account)
      end

      # Creates a new account. The class of the account varies by the attributes.
      #
      # @param [Hash] account Attributes for the account the be created
      # @return [BitlbeeConfig::Account|BitlbeeConfig::Accounts::Icq] The newly created account
      def create_new_account(account = {})
        account_class = case
                        when account[:handle] =~ /#{ BitlbeeConfig::Accounts::Facebook::USERNAME_SUFFIX }$/
                          BitlbeeConfig::Accounts::Facebook
                        when account[:server] == BitlbeeConfig::Accounts::Gtalk::DEFAULT_GTALK_SERVER
                          BitlbeeConfig::Accounts::Gtalk
                        when account[:protocol].to_s == "jabber"
                          BitlbeeConfig::Accounts::Jabber
                        when account[:protocol].to_s == "steam"
                          BitlbeeConfig::Accounts::Steam
                        when account[:protocol].to_s == "oscar"
                          BitlbeeConfig::Accounts::Icq
                        else
                          BitlbeeConfig::Account
                        end

        account_class.new(account)
      end
    end

    # @param [Hash] options
    # @option options [String] :protocol Protocol used for the account
    # @option options [String] :handle The handle / login for the account, e.g. your ICQ number
    # @option options [String] :tag A label for easy recognition of your account, e.g. "jabber-work"
    # @option options [String] :autoconnect Autoconnect to account on identify?
    # @option options [String] :server Overwrite server to connect to - for example if you use a proxy, or stunnel
    # @option options [String] :cleartext_password Cleartext password for this account. Will be encrypted before written
    # @option options [String] :password The encrypted password of the account, as it appears in the XML document (encrypted_password with the users password
    # @option options [String] :user User this account belongs to. Needed for it's cleartext password
    def initialize(options = {})
      @protocol ||= options.delete(:protocol)
      @handle ||= options.delete(:handle)
      @tag ||= options.delete(:tag)
      @autoconnect ||= options.delete(:autoconnect)
      @server ||= options.delete(:server)
      @password ||= options.delete(:password)
      @cleartext_password ||= options.delete(:cleartext_password)
      @user ||= options.delete(:user)
      @settings = options || {}
    end

    # Uniquely identify this account - currently by protocol and handle
    def id
      "#{ @protocol }##{ @handle }"
    end

    # When a cleartext password and the user's cleartext password are given, encrypt the cleartext_password with the user's cleartext password
    def regenerate_password_if_needed
      @password = @cleartext_password.encrypt_bitlbee_password(@user.cleartext_password) if @user && @user.cleartext_password && @cleartext_password
    end

    # @param [Nokogiri::XML::Builder] xml_builder All XML will be added to this builder
    def build_xml(xml_builder)
      regenerate_password_if_needed

      account_options = [:password, :protocol, :handle, :autoconnect, :tag, :server].each_with_object({}) do |option, options_hash|
        value = instance_variable_get("@#{ option }")
        options_hash[option] = value unless value.nil? || value.empty?
      end

      to_xml_with_options(xml_builder, account_options)
    end
  end
end
