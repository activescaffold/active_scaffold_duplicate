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
  Columns = Struct.new(:visible_columns_names)
  ActionConfig = Struct.new(:columns)
  ScaffoldConfig = Struct.new(:create)

  class BaseHelper
    attr_accessor :action_name, :active_scaffold_config, :base_columns

    def current_form_columns(*)
      base_columns
    end

    def active_scaffold_subform_record_actions(*)
      'existing action'
    end
  end

  class Helper < BaseHelper
    include ActiveScaffold::Helpers::DuplicateHelpers

    attr_reader :element_calls, :link_calls

    def initialize
      super
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

  def test_duplicate_uses_visible_create_columns_when_form_columns_are_missing
    helper = Helper.new
    helper.action_name = 'duplicate'
    helper.active_scaffold_config = ScaffoldConfig.new(ActionConfig.new(Columns.new(%i[name category])))

    assert_equal %i[name category], helper.current_form_columns(Object.new, nil)
  end

  def test_current_form_columns_preserves_columns_returned_by_active_scaffold
    helper = Helper.new
    helper.action_name = 'duplicate'
    helper.base_columns = %i[name description]

    assert_equal %i[name description], helper.current_form_columns(Object.new, nil)
  end

  def test_current_form_columns_remains_nil_for_other_actions
    helper = Helper.new
    helper.action_name = 'edit'

    assert_nil helper.current_form_columns(Object.new, nil)
  end

  def test_subform_actions_are_unchanged_when_duplication_is_disabled
    helper = Helper.new
    column = Column.new(Association.new(true), {duplicate: false}, {})

    assert_equal 'existing action',
                 helper.active_scaffold_subform_record_actions(column, Object.new, false, 'children')
    assert_empty helper.link_calls
  end
end
