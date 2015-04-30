module BitlbeeConfig
  # A configuration file for BitlBee. Has exactly one user
  class Config
    attr_accessor :user

    class << self
      # Create a config for every user XML in the given directory
      #
      # @param [String] directory Directory to load from
      # @return [Array<BitlbeeConfig::User>]
      def from_directory(directory)
        Dir.glob(File.join(directory, "*.xml")).each_with_object([]) do |path_to_file, config_collection|
          config_collection << BitlbeeConfig::Config.from_file(path_to_file)
        end
      end

      # Create a config for one specific user, reading the XML from a directory
      #
      # @param [String] directory Directory to load from
      # @param [String] username User to load config for
      # @return [BitlbeeConfig::User|nil]
      def from_directory_for_user(directory, username)
        from_file(File.join(directory, BitlbeeConfig::User.username_to_filename(username)))
      end

      # Create a config from an XML file
      #
      # @param [String] file_path Path to the XML configuration file
      # @return [BitlbeeConfig::Config] The created configuration object
      def from_file(file_path)
        from_xml(File.read(file_path))
      end

      # @param [String] xml The XML to parse
      # @return [BitlbeeConfig::Config] The created configuration object
      def from_xml(xml)
        doc = Nokogiri::XML(xml)

        # Bitlbee config says there can be only one user per XML file
        user_xml = doc.xpath("//user").first

        BitlbeeConfig::Config.new(user: BitlbeeConfig::User.from_xml(user_xml))
      end

      # Deletes file for a specified user name from the given directory
      #
      # @param [String] directory Directory to check for user XML files
      # @param [String] username User to delete config for
      def delete_from_directory_for_user(directory, username)
        file_to_delete = File.join(directory, BitlbeeConfig::User.username_to_filename(username))
        File.delete(file_to_delete) if File.exist?(file_to_delete)
      end
    end

    # @param [Hash] options
    # @option options [Array<BitlbeeConfig::User>] :user User this configuration belongs to
    def initialize(options = {})
      @user = options.delete(:user)
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml_builder|
        @user.build_xml(xml_builder)
      end

      builder.doc.root.to_xml
    end

    # Saves the configuration to a specified directory
    # User files are named <username.downcase>.xml
    #
    # @param [String] path_to_dir Directory to save user xml to
    def save_to_directory(path_to_dir)
      user_file_path = File.join(path_to_dir, "#{ @user.nick.downcase }.xml")

      File.open(user_file_path, "w") do |file|
        file.write(to_xml)
      end
    end
  end
end
