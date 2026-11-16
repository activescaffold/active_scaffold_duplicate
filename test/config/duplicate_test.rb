# frozen_string_literal: true

require 'test_helper'

# Minitest::Test provides refute assertions, not Active Support's assert_not aliases.
# rubocop:disable Rails/RefuteMethods
class DuplicateConfigTest < Minitest::Test
  class Core
    def model_id
      :record
    end
  end

  def setup
    @config = ActiveScaffold::Config::Duplicate.new(Core.new)
  end

  def test_defaults_are_copied_to_each_configuration
    assert_equal :dup, @config.method
    assert_nil @config.action_after_clone
    assert_equal :new, @config.action_view
    refute @config.refresh_list
  end

  def test_default_link_is_a_post_member_action
    link = ActiveScaffold::Config::Duplicate.link

    assert_equal :duplicate, link.action
    assert_equal :member, link.type
    assert_equal :post, link.method
    assert_equal :duplicate_authorized?, link.security_method
    assert_equal :duplicate_ignore?, link.ignore_method
    refute link.position
  end

  def test_instance_settings_can_override_defaults
    @config.method = :duplicate_with_associations
    @config.action_after_clone = :edit
    @config.action_view = :duplicate_form
    @config.refresh_list = true
    @config.link = :custom_link

    assert_equal :duplicate_with_associations, @config.method
    assert_equal :edit, @config.action_after_clone
    assert_equal :duplicate_form, @config.action_view
    assert @config.refresh_list
    assert_equal :custom_link, @config.link
  end

  def test_duplicate_uses_create_authorization
    assert_equal :create, ActiveScaffold::Config::Duplicate.crud_type
  end
end
# rubocop:enable Rails/RefuteMethods
