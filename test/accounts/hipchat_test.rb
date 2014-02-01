require "helper"

describe BitlbeeConfig::Accounts::Hipchat do
  describe "default settings" do
    before do
      @account = BitlbeeConfig::Accounts::Hipchat.new
    end

    it "sets a tag" do
      assert @account.tag
    end

    it "sets a nick format" do
      assert @account.settings[:nick_format]
    end
  end

  describe "username mangling" do
    it "adds the hipchat chat name suffix to the username it's not already there" do
      handle = "nilslandt"
      acc = BitlbeeConfig::Accounts::Hipchat.new(handle: handle)

      assert_equal handle + BitlbeeConfig::Accounts::Hipchat::USERNAME_SUFFIX, acc.handle
    end

    it "does not add the hipchat chat name suffix if it's already there" do
      handle = "nilslandt" + BitlbeeConfig::Accounts::Hipchat::USERNAME_SUFFIX
      acc = BitlbeeConfig::Accounts::Hipchat.new(handle: handle)

      assert_equal handle, acc.handle
    end
  end
end
