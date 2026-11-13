# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../lib/active_scaffold_duplicate/subform'

# Tests duplication of nested records submitted through a subform.
class SubformTest < Minitest::Test
  Column = Struct.new(:name)
  SubformConfig = Struct.new(:columns)
  ScaffoldConfig = Struct.new(:subform)

  class BaseController
    attr_accessor :column, :params, :record, :scope, :scaffold_config
    attr_reader :update_calls

    def initialize
      @update_calls = []
    end

    def do_edit_associated
      @column = column
      @params = params
      @record = record
      @scope = scope
    end

    def active_scaffold_config_for(_record_class)
      scaffold_config
    end

    def attributes_from_scope(attributes, scope)
      keys = scope.slice(1..-2).split('][') if scope
      keys&.each { |key| attributes = attributes[key] }
      attributes
    end

    def update_record_from_params(*arguments, **options)
      @update_calls << [arguments, options]
    end
  end

  class Controller < BaseController
    prepend ActiveScaffoldDuplicate::Subform

    def edit_associated
      do_edit_associated
    end
  end

  def setup
    @controller = Controller.new
    @controller.column = Column.new(:children)
    @controller.record = Object.new
    @controller.scaffold_config = ScaffoldConfig.new(SubformConfig.new(%i[name quantity]))
  end

  def test_duplicates_the_first_subform_row_without_changing_the_source
    attributes = {'name' => 'Copy', 'quantity' => '2'}
    @controller.params = {dup: {children: {'0' => attributes}}}

    @controller.edit_associated

    assert_equal [
      [[@controller.record, %i[name quantity], attributes], {avoid_changes: true}]
    ], @controller.update_calls
    assert_equal false, @controller.params.key?(:dup)
  end

  def test_extracts_duplicate_attributes_from_the_current_scope
    attributes = {'name' => 'Nested copy'}
    @controller.scope = '[parent]'
    @controller.params = {dup: {'parent' => {children: {'7' => attributes}}}}

    @controller.edit_associated

    assert_equal attributes, @controller.update_calls.first.first.last
  end

  def test_does_not_update_the_record_without_duplicate_parameters
    @controller.params = {}

    @controller.edit_associated

    assert_empty @controller.update_calls
  end
end
