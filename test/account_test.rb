require "helper"

describe BitlbeeConfig::Account do
  it "is uniquely identified by protocol and handle" do
    account1 = BitlbeeConfig::Account.new(protocol: :oscar, handle: "1234")
    account2 = BitlbeeConfig::Account.new(protocol: :skype, handle: "1234")
    account3 = BitlbeeConfig::Account.new(protocol: :oscar, handle: "1234")
    account4 = BitlbeeConfig::Account.new(protocol: :skype, handle: "12345")

    refute account1.id == account2.id
    assert account1.id == account3.id
    refute account2.id == account4.id
  end

  describe "password regeneration" do
    before do
      @cleartext_password = "cleartext_password"
      @user_cleartext_password = "user_cleartext_password"
      @user = BitlbeeConfig::User.new(nick: "Nils", cleartext_password: @user_cleartext_password)
      @encrypted_password = "encrypted_password"

      String.any_instance.stubs(:encrypt_bitlbee_password).returns(@cleartext_password + @user_cleartext_password)
    end

    it "overwrites password if cleartext password AND user cleartext password are given" do
      account = BitlbeeConfig::Account.new(cleartext_password: @cleartext_password,
                                           user: @user,
                                           password: @encrypted_password)

      assert_buildable_object_attribute_equals(account, :password, @cleartext_password.encrypt_bitlbee_password)
    end

    it "doesn't touch password if no cleartext password is given" do
      account = BitlbeeConfig::Account.new(user: @user,
                                           password: @encrypted_password)

      assert_buildable_object_attribute_equals(account, :password, @encrypted_password)
    end

    it "doesn't touch password if no user cleartext password is given" do
      account = BitlbeeConfig::Account.new(cleartext_password: @cleartext_password,
                                           password: @encrypted_password)

      assert_buildable_object_attribute_equals(account, :password, @encrypted_password)
    end
  end

  describe "creating from xml" do
    before do
      @account = load_config_from_fixture("nils").user.accounts.first
    end

    it "reads the handle from attribute" do
      assert_equal "12345678", @account.handle
    end

    it "reads the tag from attribute" do
      assert_equal "icq", @account.tag
    end

    it "reads the password from attribute" do
      assert_equal "bbbbbbbbbbbbbbbbbbbbb", @account.password
    end

    it "reads the server from attribute" do
      assert_equal "127.0.0.1", @account.server
    end

    it "reads the autoconnect flag from attribute" do
      assert_equal "true", @account.autoconnect
    end

    describe "account creation class based on xml" do
      it "creates a generic account if nothing special is specified" do
        account = BitlbeeConfig::Account.create_new_account
        assert_kind_of BitlbeeConfig::Account, account
      end

      it "creates an ICQ account when protocol is 'oscar'" do
        account = BitlbeeConfig::Account.create_new_account(protocol: :oscar)
        assert_kind_of BitlbeeConfig::Accounts::Icq, account
      end
    end
  end

  describe "building xml" do
    it "assigns handle as an attribute" do
      handle = "testhandle"

      account = BitlbeeConfig::Account.new(handle: handle)

      assert_buildable_object_attribute_equals(account, :handle, handle)
    end

    it "assigns protocol as an attribute" do
      protocol = "testprotocol"

      account = BitlbeeConfig::Account.new(protocol: protocol)

      assert_buildable_object_attribute_equals(account, :protocol, protocol)
    end

    it "assigns autoconnect as an attribute" do
      autoconnect = "testautoconnect"

      account = BitlbeeConfig::Account.new(autoconnect: autoconnect)

      assert_buildable_object_attribute_equals(account, :autoconnect, autoconnect)
    end

    it "assigns server as an attribute" do
      server = "testserver"

      account = BitlbeeConfig::Account.new(server: server)

      assert_buildable_object_attribute_equals(account, :server, server)
    end

    it "assigns tag as an attribute" do
      tag = "testtag"

      account = BitlbeeConfig::Account.new(tag: tag)

      assert_buildable_object_attribute_equals(account, :tag, tag)
    end

    it "assigns settings" do
      settings = { nick_format: "%testformat" }

      account = BitlbeeConfig::Account.new(settings)

      assert_buildable_object_has_settings(account, settings)
    end
  end
end
