require "helper"

describe BitlbeeConfig::User do
  it "turns all unrecognized options into settings" do
    settings = { testsetting: "testvalue", settingtwo: "valuetwo" }

    user = BitlbeeConfig::User.new(settings)

    assert_equal settings, user.settings
  end

  it "turns a given username into a file name" do
    assert_equal "nils.xml", BitlbeeConfig::User.username_to_filename("Nils")
  end

  describe "password regeneration" do
    it "overwrites password if cleartext password is given" do
      cleartext_password = "cleartext_password"

      String.any_instance.stubs(:to_bitlbee_password_hash).returns(cleartext_password.reverse.upcase)

      user = BitlbeeConfig::User.new(password: "encryptedpw", cleartext_password: cleartext_password)

      assert_buildable_object_attribute_equals(user, :password, cleartext_password.to_bitlbee_password_hash)
    end

    it "doesn't touch password if no cleartext password is given" do
      encrypted_password = "encryptedpw"

      String.any_instance.stubs(:matches_bitlbee_password_hash?).returns(true)

      user = BitlbeeConfig::User.new(password: encrypted_password)

      assert_buildable_object_attribute_equals(user, :password, encrypted_password)
    end
  end

  describe "relationship with accounts" do
    before do
      @user = BitlbeeConfig::User.new(nick: "Nils")
    end

    it "allows adding accounts" do
      account = BitlbeeConfig::Account.new(protocol: :oscar, handle: "12345678")

      @user.add_or_replace_account(account)
      assert_equal 1, @user.accounts.count
      assert_equal account, @user.accounts.first
    end

    it "replaces an existing account if a new account with the same ID is added" do
      old_account = BitlbeeConfig::Account.new(protocol: :oscar, handle: "12345678")
      new_account = BitlbeeConfig::Account.new(protocol: :oscar, handle: "12345678")

      @user.add_or_replace_account(old_account)
      @user.add_or_replace_account(new_account)

      assert_equal 1, @user.accounts.count
      assert_equal new_account, @user.accounts.first
    end

    it "injects the user into the account" do
      user = BitlbeeConfig::User.new(nick: "Nils", cleartext_password: "password")
      config = BitlbeeConfig::Config.new(user: user)
      account = BitlbeeConfig::Account.new(protocol: :oscar, handle: "12345678")

      config.user.add_or_replace_account(account)

      assert_equal config.user, account.user
    end

    describe "account removal" do
      before do
        @account = BitlbeeConfig::Accounts::Icq.new(handle: "12345678")
        @user = BitlbeeConfig::User.new(nick: "Nils")
        @user.add_or_replace_account(@account)
      end

      it "removes an account by id" do
        @user.remove_account_by_id(@account.id)
        assert_equal 0, @user.accounts.count
      end

      it "removes a given account" do
        @user.remove_account(@account)
        assert_equal 0, @user.accounts.count
      end
    end
  end

  describe "creating from xml" do
    before do
      @user = load_config_from_fixture("nils").user
    end

    it "reads the nick from attribute" do
      assert_equal "Nils", @user.nick
    end

    it "reads the password from attribute" do
      assert_equal "aaaaaaaaaaaaaaaaaaaaaaaaaaaa", @user.password
    end

    it "reads the version from attribute" do
      assert_equal "1", @user.version
    end

    describe "creating accounts" do
      it "delegates account creation to account objects" do
        BitlbeeConfig::Account.expects(:from_xml).once

        # rubocop:disable HandleExceptions
        # since "from_xml" is stubbed, nothing will be built, resulting in an error. That's fine for this test
        begin
          load_config_from_fixture "nils"
        rescue NoMethodError
        end
        # rubocop:enable HandleExceptions
      end

      it "creates accounts" do
        config = load_config_from_fixture "nils"
        assert_equal 1, config.user.accounts.count
        assert_kind_of BitlbeeConfig::Account, config.user.accounts.first
      end

      it "inserts itself as the user for the accounts" do
        config = load_config_from_fixture "nils"

        assert_equal config.user, config.user.accounts.first.user
      end
    end

    describe "creating channels" do
      it "delegates channel creation to channel objects" do
        BitlbeeConfig::Channel.expects(:from_xml).once
        load_config_from_fixture "nils"
      end

      it "creates channels" do
        config = load_config_from_fixture "nils"
        assert_equal 1, config.user.channels.count
        assert_kind_of BitlbeeConfig::Channel, config.user.channels.first
      end
    end

    it "reads settings from sub elements" do
      config = load_config_from_fixture "nils"
      assert_equal "I'm busy", config.user.settings["away"]
    end
  end

  describe "building xml" do
    it "assigns nick as an attribute" do
      nick = "testnick"

      user = BitlbeeConfig::User.new(nick: nick)

      assert_buildable_object_attribute_equals(user, :nick, nick)
    end

    it "assigns password as an attribute" do
      password = "testpassword"

      user = BitlbeeConfig::User.new(password: password)

      assert_buildable_object_attribute_equals(user, :password, password)
    end

    it "assigns version as an attribute" do
      version = "testversion"

      user = BitlbeeConfig::User.new(version: version)

      assert_buildable_object_attribute_equals(user, :version, version)
    end

    it "assigns settings as sub elements" do
      settings = { testsetting: "testvalue" }

      user = BitlbeeConfig::User.new(settings.merge(nick: "Nils"))

      assert_buildable_object_has_settings(user, settings)
    end

    it "adds xml from all accounts" do
      xml_builder = Nokogiri::XML::Builder.new

      account1 = BitlbeeConfig::Account.new(protocol: :oscar, handle: "1234")
      account2 = BitlbeeConfig::Account.new(protocol: :skype, handle: "1234")

      user = BitlbeeConfig::User.new(nick: "Nils", accounts: [account1, account2])

      account1.expects(:build_xml).once
      account2.expects(:build_xml).once

      user.build_xml(xml_builder)
    end

    it "adds xml from all channels" do
      xml_builder = Nokogiri::XML::Builder.new

      channel1 = BitlbeeConfig::Channel.new(name: "test1")
      channel2 = BitlbeeConfig::Channel.new(name: "test2")

      user = BitlbeeConfig::User.new(nick: "Nils", channels: [channel1, channel2])

      channel1.expects(:build_xml).once
      channel2.expects(:build_xml).once

      user.build_xml(xml_builder)
    end

    it "adds channels as sub elements" do
    end
  end
end
