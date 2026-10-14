# frozen_string_literal: true

require 'minitest/autorun'

module ActiveScaffold
  module Helpers
  end
end

require_relative '../../lib/active_scaffold/helpers/duplicate_helpers'

class DuplicateHelpersTest < Minitest::Test
  Association = Struct.new(:collection?)
  Column = Struct.new(:association, :form_ui_options, :options)

  class BaseHelper
    def active_scaffold_subform_record_actions(*)
      'existing action'
    end
  end

  class Helper < BaseHelper
    include ActiveScaffold::Helpers::DuplicateHelpers

    attr_reader :element_calls, :link_calls

    def initialize
      @element_calls = []
      @link_calls = []
    end

    def as_element_attributes(key, **options)
      @element_calls << [key, options]
      options.merge(class: "adapter #{options[:class]}")
    end

    def as_(key)
      key.to_s
    end

    def link_to(label, url, options)
      @link_calls << [label, url, options]
      'duplicate action'
    end

    def safe_join(values)
      values.join
    end
  end

  def test_subform_duplicate_link_uses_ui_adapter_attributes
    helper = Helper.new
    column = Column.new(Association.new(true), {duplicate: true}, {})

    assert_equal 'duplicate actionexisting action',
                 helper.active_scaffold_subform_record_actions(column, Object.new, false, 'children')
    assert_equal [
      :subform_record_duplicate,
      {
        class: 'dup',
        style: 'display: none;',
        remote: true,
        data: {scope: 'children'}
      }
    ], helper.element_calls.first
    assert_equal 'adapter dup', helper.link_calls.first.last[:class]
  end
end
