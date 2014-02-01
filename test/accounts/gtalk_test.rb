require "helper"

describe BitlbeeConfig::Accounts::Gtalk do
  describe "default settings" do
    before do
      @account = BitlbeeConfig::Accounts::Gtalk.new
    end

    it "sets a tag" do
      assert @account.tag
    end

    it "sets a nick format" do
      assert @account.settings[:nick_format]
    end

    it "sets a server" do
      assert @account.server
    end

    it "enables oauth" do
      assert @account.settings[:oauth]
    end
  end
end
