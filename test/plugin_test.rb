# frozen_string_literal: true

require 'test_helper'
require 'active_scaffold/extensions/routing_mapper'

class DuplicatePluginTest < Minitest::Test
  def test_entry_point_registers_javascript_and_exposes_root
    assert_includes ActiveScaffold.javascripts, 'active_scaffold_duplicate'
    assert_equal File.expand_path('..', __dir__), File.expand_path(ActiveScaffoldDuplicate.root)
  end

  def test_extensions_load_action_configuration_and_helpers
    expected_sources = {
      ActiveScaffold::Actions::Duplicate.instance_method(:duplicate) =>
        'lib/active_scaffold/actions/duplicate.rb',
      ActiveScaffold::Config::Duplicate.instance_method(:initialize) =>
        'lib/active_scaffold/config/duplicate.rb',
      ActiveScaffold::Helpers::DuplicateHelpers.instance_method(:current_form_columns) =>
        'lib/active_scaffold/helpers/duplicate_helpers.rb'
    }

    expected_sources.each do |method, relative_path|
      assert_equal File.expand_path("../#{relative_path}", __dir__), method.source_location.first
    end
  end

  def test_engine_defines_named_initializers
    assert_equal(
      %w[
        active_scaffold_duplicate.action_view
        active_scaffold_duplicate.routes
        active_scaffold_duplicate.extensions
      ],
      ActiveScaffoldDuplicate::Engine.initializers.map(&:name)
    )
  end

  def test_routes_initializer_registers_get_and_post
    run_initializer('active_scaffold_duplicate.routes')

    routes = ActiveScaffold::Routing::ACTIVE_SCAFFOLD_CORE_ROUTING.fetch(:member)
    assert_equal %i[post get], routes[:duplicate]
  end

  def test_action_view_initializer_installs_duplicate_helpers
    run_initializer('active_scaffold_duplicate.action_view')

    assert_includes ActionView::Base.ancestors, ActiveScaffold::Helpers::DuplicateHelpers
  end

  def test_extensions_initializer_prepends_subform_behavior
    run_initializer('active_scaffold_duplicate.extensions')

    assert_includes ActiveScaffold::Actions::Subform.ancestors, ActiveScaffoldDuplicate::Subform
  end

  private

  def run_initializer(name)
    ActiveScaffoldDuplicate::Engine.initializers.find { |initializer| initializer.name == name }.run
  end
end
