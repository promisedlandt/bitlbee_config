module BitlbeeConfig
  module XmlBuildable
    def to_xml_with_options(xml_builder, options = {}, &block)
      # Accounts can have many different classes, but the element is always named "account"
      element_name = case
                     when self.is_a?(BitlbeeConfig::Account)
                       "account"
                     else
                       self.class.name.split("::").last.downcase
                     end

      xml_builder.send(element_name, options) do |xml|
        if @settings
          @settings.each do |setting_name, setting_value|
            xml.setting(name: setting_name) do |setting_xml|
              setting_xml.text setting_value
            end
          end
        end

        block.call(xml) if block
      end
    end
  end
end
