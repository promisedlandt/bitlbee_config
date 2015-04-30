require "bundler/setup"

require "coveralls"
Coveralls.wear!

require "minitest/autorun"
require "mocha/setup"

require "tmpdir"
require "bitlbee_config"

def get_tmp_dir(additional_prefix = "")
  Dir.mktmpdir("#{ File.split(File.expand_path(File.join(__FILE__, "..", ".."))).last }_test_#{ Time.now.strftime("%F-%H-%M-%S") }_#{ additional_prefix }")
end

def get_fixture_by_name(name)
  File.expand_path(File.join(__FILE__, "..", "fixtures", BitlbeeConfig::User.username_to_filename(name)))
end

def load_config_from_fixture(fixture)
  BitlbeeConfig::Config.from_file(get_fixture_by_name(fixture))
end

def assert_buildable_object_attribute_equals(buildable_object, attribute_name, attribute_value)
  xml_builder = Nokogiri::XML::Builder.new
  buildable_object.build_xml(xml_builder)

  assert_includes xml_builder.doc.root.to_xml, "#{ attribute_name }=\"#{ attribute_value }\""
end

def build_xml_from_object(buildable_object)
  xml_builder = Nokogiri::XML::Builder.new
  buildable_object.build_xml(xml_builder)

  xml_builder.doc.root.to_xml
end

def assert_buildable_object_has_settings(buildable_object, settings)
  xml = build_xml_from_object(buildable_object)

  settings.each do |setting_name, setting_value|
    assert_includes xml, "<setting name=\"#{ setting_name }\">#{ setting_value }</setting>"
  end
end

def refute_buildable_object_has_settings(buildable_object, settings)
  xml = build_xml_from_object(buildable_object)

  settings.each do |setting_name, setting_value|
    refute_includes xml, "<setting name=\"#{ setting_name }\">#{ setting_value }</setting>"
  end
end

def mocked_shellout(return_value = "")
  result = mock.stubs(:run_command)
  result.stubs(:error!).returns(false)
  result.stubs(:stdout).returns(return_value)
  result.stubs(:exitstatus).returns(0)

  result
end
