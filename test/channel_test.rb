require "helper"

describe BitlbeeConfig::Channel do
  it "turns all unrecognized options into settings" do
    settings = { testsetting: "testvalue", settingtwo: "valuetwo" }

    channel = BitlbeeConfig::Channel.new(settings)

    assert_equal settings, channel.settings
  end

  describe "creating from xml" do
    before do
      @channel = load_config_from_fixture("nils").user.channels.first
    end

    it "reads the name from attribute" do
      assert_equal "&bitlbee", @channel.name
    end

    it "reads the type from attribute" do
      assert_equal "control", @channel.type
    end

    it "reads settings from sub elements" do
      assert_equal({ auto_join: "true" }, @channel.settings)
    end
  end

  describe "building xml" do
    it "assigns name as an attribute" do
      name = "testchannel"

      channel = BitlbeeConfig::Channel.new(name: name)

      assert_buildable_object_attribute_equals(channel, :name, name)
    end

    it "assigns type as an attribute" do
      type = "local"

      channel = BitlbeeConfig::Channel.new(type: type)

      assert_buildable_object_attribute_equals(channel, :type, type)
    end

    it "assigns settings as sub elements" do
      settings = { testsetting: "testvalue" }

      channel = BitlbeeConfig::Channel.new(settings)

      assert_buildable_object_has_settings(channel, settings)
    end
  end
end
