# frozen_string_literal: true

require 'erb'
require 'test_helper'

# Minitest::Test provides refute assertions, not Active Support's assert_not aliases.
# rubocop:disable Rails/RefuteMethods
class DuplicateTemplateTest < Minitest::Test
  VIEW_PATH = File.expand_path('../../app/views', __dir__)
  LOOKUP_CONTEXT = ActionView::LookupContext.new([VIEW_PATH])

  DuplicateConfig = Struct.new(:refresh_list, :action_after_clone)
  ScaffoldConfig = Struct.new(:duplicate)
  Record = Struct.new(:id)

  class Controller
    def initialize(successful)
      @successful = successful
    end

    def successful?
      @successful
    end
  end

  class View < ActionView::Base.with_empty_template_cache
    attr_reader :active_scaffold_config, :controller, :render_calls

    def initialize(successful:, refresh_list: false, action_after_clone: nil)
      super(LOOKUP_CONTEXT, {}, nil)
      @controller = Controller.new(successful)
      @active_scaffold_config = ScaffoldConfig.new(DuplicateConfig.new(refresh_list, action_after_clone))
      @record = Record.new(37)
      @render_calls = []
    end

    def render(options = {}, locals = {}, &)
      if @render_root
        @render_root = false
        super
      else
        render_options = options.dup
        partial = render_options.delete(:partial)
        render_options = locals if partial.nil?
        partial ||= options
        render_calls << [partial, render_options]
        ActiveSupport::SafeBuffer.new("rendered-#{partial}")
      end
    end

    def active_scaffold_messages_id
      'messages'
    end

    def active_scaffold_id
      'records'
    end

    def escape_javascript(value)
      "escaped-#{value}"
    end

    def javascript_literal(value)
      value.inspect
    end

    def action_link_id(action, id)
      "#{action}-#{id}"
    end

    def evaluate
      @render_root = true
      render template: 'active_scaffold_overrides/duplicate'
    ensure
      @render_root = false
    end
  end

  def test_failed_duplicate_only_updates_messages
    view = View.new(successful: false)

    output = view.evaluate

    assert_includes output, 'rendered-update_messages'
    refute_includes output, 'ActiveScaffold.create_record_row'
    assert_equal [['update_messages', {locals: {messages_id: 'messages'}}]], view.render_calls
  end

  def test_successful_duplicate_refreshes_list_when_configured
    view = View.new(successful: true, refresh_list: true)

    output = view.evaluate

    assert_includes output, 'rendered-refresh_list'
    refute_includes output, 'ActiveScaffold.create_record_row'
    assert_equal %w[update_messages refresh_list], view.render_calls.map(&:first)
  end

  def test_successful_duplicate_inserts_row_and_opens_follow_up_action
    view = View.new(successful: true, action_after_clone: :edit)

    output = view.evaluate

    assert_includes output, "ActiveScaffold.create_record_row('records','escaped-rendered-list_record'"
    assert_includes output, 'rendered-update_calculations'
    assert_includes output, "ActiveScaffold.find_action_link('edit-37')"
    assert_equal %w[update_messages list_record update_calculations], view.render_calls.map(&:first)
    assert_equal({locals: {record: Record.new(37)}}, view.render_calls[1].last)
    assert_equal({formats: [:js]}, view.render_calls[2].last)
  end
end
# rubocop:enable Rails/RefuteMethods
