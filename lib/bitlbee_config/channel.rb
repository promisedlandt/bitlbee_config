module BitlbeeConfig
  # A channel on the bitlbee server. Can either be a control channel, in which you issue commands to the BitlBee root user, or a chat channel, which is a multi contact conversation
  class Channel
    include BitlbeeConfig::XmlBuildable

    attr_accessor :name, :type, :settings

    class << self
      # @param [Nokogiri::XML::Element] xml XML element to create channel from
      # @return [BitlbeeConfig::Channel] The newly created channel
      def from_xml(xml)
        new_channel = {}

        # get setting attributes
        xml.attributes.each do |att_name, att_value|
          new_channel[att_name.to_sym] = att_value.text
        end

        # get setting children
        xml.children.select { |node| node.is_a?(Nokogiri::XML::Element) }.each do |setting_element|
          new_channel[setting_element.values.first.to_sym] = setting_element.text
        end

        BitlbeeConfig::Channel.new(new_channel)
      end
    end

    # @param [Hash] options
    # @option options [String] :name Channel name. Don't forget # or &
    # @option options ["control"|"chat"] :type Type of channel
    # @option options [String] All other entries will be converted to settings
    def initialize(options = {})
      @name = options.delete(:name)
      @type = options.delete(:type)
      @settings = options || {}
    end

    # @param [Nokogiri::XML::Builder] xml_builder All XML will be added to this builder
    def build_xml(xml_builder)
      to_xml_with_options(xml_builder, name: @name, type: @type)
    end
  end
end
