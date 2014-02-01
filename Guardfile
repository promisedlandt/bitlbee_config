guard :minitest do
  watch(%r{^test/(.*)_test\.rb})
  watch("lib/bitlbee_config.rb") { "test" }
  watch(%r{^lib/bitlbee_config/(.*/)?([^/]+)\.rb})     { |m| "test/#{ m[1] }#{ m[2] }_test.rb" }
  watch(%r{^test/helper\.rb})    { "test" }
  watch(%r{^test/fixtures/.*\.xml}) { "test" }
end
