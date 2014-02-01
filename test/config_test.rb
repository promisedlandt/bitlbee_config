require "helper"

describe BitlbeeConfig::Config do
  it "initializes with a single given user" do
    new_user = BitlbeeConfig::User.new(nick: "test")
    config = BitlbeeConfig::Config.new(user: new_user)

    assert_kind_of BitlbeeConfig::User, config.user
    assert_equal config.user, new_user
  end

  describe "deleting user configuration files" do
    before do
      @config_dir = get_tmp_dir
      FileUtils.cp([get_fixture_by_name("nils"), get_fixture_by_name("malte")], @config_dir)
    end

    it "deletes a user configuration file from a given directory" do
      assert File.exists?(File.join(@config_dir, "nils.xml"))

      BitlbeeConfig::Config.delete_from_directory_for_user(@config_dir, "Nils")

      refute File.exists?(File.join(@config_dir, "nils.xml"))
      assert File.exists?(File.join(@config_dir, "malte.xml"))
    end

    after do
      FileUtils.rm_rf @config_dir
    end
  end

  describe "saving to file system" do
    before do
      @output_dir = get_tmp_dir
    end

    it "creates a file for every user" do
      user_names = %w(user_one user_two)

      configs = user_names.collect do |user_name|
        BitlbeeConfig::Config.new(user: BitlbeeConfig::User.new(nick: user_name))
      end

      configs.each { |config| config.save_to_directory(@output_dir) }

      user_names.each do |user_name|
        assert File.exists?(File.join(@output_dir, "#{ user_name }.xml"))
      end
    end

    it "downcases all filenames" do
      user_name = "Nils"

      config = BitlbeeConfig::Config.new(user: BitlbeeConfig::User.new(nick: user_name))
      config.save_to_directory(@output_dir)

      assert File.exists?(File.join(@output_dir, "#{ user_name.downcase }.xml"))
    end

    after do
      FileUtils.rm_rf @output_dir
    end
  end

  describe "conversion to string" do
    it "delegates building each user to the user object" do
      user = BitlbeeConfig::User.new(nick: "Nils")
      user.expects(:build_xml).once

      config = BitlbeeConfig::Config.new(user: user)

      # rubocop:disable HandleExceptions
      # since "build_xml" is stubbed, nothing will be built, resulting in an error. That's fine for this test
      begin
        config.to_xml
      rescue NoMethodError
      end
      # rubocop:enable HandleExceptions
    end
  end

  describe "creating from xml" do
    describe "reading multiple xml files from directory" do
      before do
        @config_dir = get_tmp_dir
        FileUtils.cp([get_fixture_by_name("nils"), get_fixture_by_name("malte")], @config_dir)
      end

      it "creates multiple configs for multiple files in a directory" do
        configs = BitlbeeConfig::Config.from_directory(@config_dir)

        assert_equal 2, configs.count
        assert configs.all? { |config| config.is_a?(BitlbeeConfig::Config) }
      end

      it "loads config for a specific user from a given directory" do
        config = BitlbeeConfig::Config.from_directory_for_user(@config_dir, "nils")

        assert_kind_of BitlbeeConfig::User, config.user
        assert_equal "Nils", config.user.nick
      end

      after do
        FileUtils.rm_rf @config_dir
      end
    end

    it "finds a user in an xml config" do
      config = load_config_from_fixture "nils"
      assert_equal config.user.nick, "Nils"
    end

    it "delegates the user to a new user object" do
      BitlbeeConfig::User.expects(:from_xml).once
      load_config_from_fixture "nils"
    end
  end
end
