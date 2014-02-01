require "helper"

describe BitlbeeConfig::Accounts::Facebook do
  describe "default settings" do
    before do
      @account = BitlbeeConfig::Accounts::Facebook.new
    end

    it "sets a tag" do
      assert @account.tag
    end

    it "sets a nick format" do
      assert @account.settings[:nick_format]
    end
  end

  describe "username mangling" do
    it "adds the facebook chat name suffix to the username it's not already there" do
      handle = "nilslandt"
      acc = BitlbeeConfig::Accounts::Facebook.new(handle: handle)

      assert_equal handle + BitlbeeConfig::Accounts::Facebook::USERNAME_SUFFIX, acc.handle
    end

    it "does not add the facebook chat name suffix if it's already there" do
      handle = "nilslandt" + BitlbeeConfig::Accounts::Facebook::USERNAME_SUFFIX
      acc = BitlbeeConfig::Accounts::Facebook.new(handle: handle)

      assert_equal handle, acc.handle
    end

    it "lowercases the username" do
      handle = "NilsLandt" + BitlbeeConfig::Accounts::Facebook::USERNAME_SUFFIX
      acc = BitlbeeConfig::Accounts::Facebook.new(handle: handle)

      assert_equal handle.downcase, acc.handle
    end
  end

  describe "authentication strategies" do
    before do
      @oauth_settings = { oauth: "on" }
    end

    it "uses oauth as default" do
      acc = BitlbeeConfig::Accounts::Facebook.new(handle: "nils")

      assert_equal :oauth, acc.auth_strategy
    end

    it "has a password when oauth is used" do
      user = BitlbeeConfig::User.new(nick: "Nils", cleartext_password: "testpwd")
      acc = BitlbeeConfig::Accounts::Facebook.new(handle: "nils", user: user)
      String.any_instance.stubs(:encrypt_bitlbee_password).returns("dontcare")

      acc.regenerate_password_if_needed

      assert acc.password.length > 0
    end

    it "has an oauth setting when oauth strategy is used" do
      acc = BitlbeeConfig::Accounts::Facebook.new(handle: "nils")

      assert_buildable_object_has_settings acc, @oauth_settings
    end

    it "has no oauth setting when password strategy is used" do
      acc = BitlbeeConfig::Accounts::Facebook.new(handle: "nils",
                                                  auth_strategy: :password)

      refute_buildable_object_has_settings acc, @oauth_settings
    end

    it "should not create an 'auth_strategy' setting" do
      auth_strategy_settings = { auth_strategy: :password }
      acc = BitlbeeConfig::Accounts::Facebook.new(auth_strategy_settings.merge(handle: "nils"))

      refute_buildable_object_has_settings acc, auth_strategy_settings
    end
  end
end
