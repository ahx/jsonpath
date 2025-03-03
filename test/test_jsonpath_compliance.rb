# frozen_string_literal: true

require 'minitest/autorun'
require 'jsonpath'
require 'json'

class TestJsonpathCompliance < MiniTest::Unit::TestCase
  skipped = [
    'whitespace, filter, space between parenthesized expression and bracket',
    'whitespace, filter, return between parenthesized expression and bracket',
    'filter, group terms, left',
    'whitespace, filter, tab between parenthesized expression and bracket'
  ]
  JSON.parse(File.read('test/jsonpath-compliance-test-suite/cts.json')).fetch('tests').each_with_index do |test, index|
    name = test['name']
    method_name = name.gsub(/[^a-z0-9]+/, '_').sub(/_$/, '')
    define_method("test_jsonpath_compliance_#{method_name}") do
      skip "#{name} – skipping" if skipped.include?(name)
      if test.key?('result')
        result = Timeout.timeout(1) do
          JsonPath.new(test.fetch('selector')).on(test['document'])
        end
        assert_equal(test['result'], result, "Test: #{name.inspect}")
      elsif test['invalid_selector']
        skip "skipping #{name} – invalid_selector #{test.fetch('selector').inspect}"
      else
        raise "don't know how to test #{name} – #{test.inspect}"
      end
    end
  end
end
