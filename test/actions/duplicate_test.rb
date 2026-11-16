# frozen_string_literal: true

require 'test_helper'

# Minitest::Test provides refute assertions, not Active Support's assert_not aliases.
# rubocop:disable Rails/RefuteMethods
class DuplicateActionTest < Minitest::Test
  Request = Struct.new(:post?)
  Columns = Struct.new(:visible_columns_names)
  CreateConfig = Struct.new(:columns)
  Link = Struct.new(:security_method)

  class DuplicateConfig
    attr_accessor :method, :action_after_clone, :action_view, :refresh_list, :formats, :link

    def self.link
      DuplicateActionTest::Link.new(:can_duplicate?)
    end

    def initialize(**attributes)
      attributes.each { |name, value| public_send("#{name}=", value) }
    end
  end
  ScaffoldConfig = Struct.new(:duplicate, :create, :formats)

  class Record
    attr_accessor :id, :save_result
    attr_reader :save_calls

    def initialize(id: 9, save_result: true)
      @id = id
      @save_result = save_result
      @save_calls = 0
    end

    def duplicate_record
      @duplicate_record ||= self.class.new(id: 27, save_result: save_result)
    end

    def save
      @save_calls += 1
      save_result
    end

    def to_label
      'Copied record'
    end
  end

  class SerializedResponse
    attr_reader :json_options, :xml_options

    def to_json(options)
      @json_options = options
      'json response'
    end

    def to_xml(options)
      @xml_options = options
      'xml response'
    end
  end

  class Controller
    def self.before_action(*); end

    include ActiveScaffold::Actions::Duplicate

    attr_accessor :active_scaffold_config, :authorization, :old_record, :params, :request,
                  :response_location, :response_object, :response_status
    attr_reader :calls, :flash, :render_options

    def initialize(post: false, save_result: true)
      @params = {id: '9'}
      @request = Request.new(post)
      @old_record = Record.new(save_result: save_result)
      duplicate = DuplicateConfig.new(method: :duplicate_record, action_after_clone: nil, action_view: :new,
                                      refresh_list: false, formats: [:json], link: nil)
      @active_scaffold_config = ScaffoldConfig.new(duplicate, CreateConfig.new(Columns.new(%i[name status])),
                                                   %i[html xml])
      @authorization = true
      @flash = {}
      @calls = []
      @response_object = SerializedResponse.new
      @response_status = 201
      @response_location = '/records/27'
    end

    def find_if_allowed(id, options)
      calls << [:find_if_allowed, id, options]
      old_record
    end

    def before_duplicate_new(record)
      calls << [:before_duplicate_new, record]
    end

    def before_duplicate_save(record)
      calls << [:before_duplicate_save, record]
    end

    def after_duplicate_save(record)
      calls << [:after_duplicate_save, record]
    end

    def respond_to_action(action)
      calls << [:respond_to_action, action]
    end

    attr_writer :successful

    def successful?
      @successful
    end

    def authorized_for?(**options)
      calls << [:authorized_for, options]
      authorization
    end

    def can_duplicate?
      authorization
    end

    def as_(key, **options)
      [key, options]
    end

    def params_for(**options)
      options
    end

    def redirect_to(options)
      calls << [:redirect_to, options]
    end

    def return_to_main
      calls << [:return_to_main]
    end

    def do_refresh_list
      calls << [:do_refresh_list]
    end

    def render(options)
      @render_options = options
    end

    def default_formats
      %i[html js]
    end

    public :duplicate_authorized?, :duplicate_authorized_filter, :duplicate_formats,
           :duplicate_respond_to_html, :duplicate_respond_to_json, :duplicate_respond_to_js,
           :duplicate_respond_to_xml
  end

  def test_get_builds_copy_and_opens_configured_form
    controller = Controller.new
    controller.active_scaffold_config.duplicate.action_view = :duplicate_form

    controller.duplicate

    copy = controller.old_record.duplicate_record
    assert_equal copy, controller.instance_variable_get(:@record)
    refute_includes controller.params, :id
    assert_includes controller.calls, [:find_if_allowed, '9', {crud_type: :read, action: :duplicate}]
    assert_includes controller.calls, [:before_duplicate_new, copy]
    assert_includes controller.calls, %i[respond_to_action duplicate_form]
  end

  def test_post_saves_copy_and_runs_success_callbacks
    controller = Controller.new(post: true)

    controller.duplicate

    copy = controller.old_record.duplicate_record
    assert_equal 1, copy.save_calls
    assert controller.successful?
    assert_includes controller.calls, [:before_duplicate_save, copy]
    assert_includes controller.calls, [:after_duplicate_save, copy]
    assert_includes controller.calls, %i[respond_to_action duplicate]
  end

  def test_failed_post_skips_success_callback
    controller = Controller.new(post: true, save_result: false)

    controller.duplicate

    refute controller.successful?
    refute(controller.calls.any? { |call| call.first == :after_duplicate_save })
  end

  def test_authorization_uses_create_permission_and_reason
    controller = Controller.new

    assert controller.duplicate_authorized?
    assert_includes controller.calls, [:authorized_for, {crud_type: :create, action: :duplicate, reason: true}]
  end

  def test_html_success_redirects_to_action_after_clone
    controller = Controller.new
    controller.successful = true
    controller.active_scaffold_config.duplicate.action_after_clone = :edit
    controller.instance_variable_set(:@record, Record.new(id: 42))

    controller.duplicate_respond_to_html

    assert_equal [:created_model, {model: 'Copied record'}], controller.flash[:info]
    assert_includes controller.calls, [:redirect_to, {action: :edit, id: 42}]
  end

  def test_html_success_returns_to_main_without_follow_up_action
    controller = Controller.new
    controller.successful = true
    controller.instance_variable_set(:@record, Record.new)

    controller.duplicate_respond_to_html

    assert_includes controller.calls, [:return_to_main]
  end

  def test_html_failure_returns_to_main
    controller = Controller.new
    controller.successful = false

    controller.duplicate_respond_to_html

    assert_includes controller.calls, [:return_to_main]
    assert_empty controller.flash
  end

  def test_javascript_refreshes_the_list_when_configured
    controller = Controller.new
    controller.successful = true
    controller.active_scaffold_config.duplicate.refresh_list = true

    controller.duplicate_respond_to_js

    assert_includes controller.calls, [:do_refresh_list]
    assert_equal({action: 'duplicate'}, controller.render_options)
  end

  def test_javascript_does_not_refresh_after_failure
    controller = Controller.new
    controller.successful = false
    controller.active_scaffold_config.duplicate.refresh_list = true

    controller.duplicate_respond_to_js

    refute(controller.calls.any? { |call| call.first == :do_refresh_list })
    assert_equal({action: 'duplicate'}, controller.render_options)
  end

  def test_xml_response_serializes_visible_create_columns
    controller = Controller.new

    controller.duplicate_respond_to_xml

    assert_equal({only: %i[name status]}, controller.response_object.xml_options)
    assert_equal 'xml response', controller.render_options[:xml]
    assert_equal Mime[:xml], controller.render_options[:content_type]
    assert_equal 201, controller.render_options[:status]
    assert_equal '/records/27', controller.render_options[:location]
  end

  def test_json_response_serializes_visible_create_columns
    controller = Controller.new

    controller.duplicate_respond_to_json

    assert_equal({only: %i[name status]}, controller.response_object.json_options)
    assert_equal 'json response', controller.render_options[:text]
    assert_equal Mime[:json], controller.render_options[:content_type]
  end

  def test_authorization_filter_uses_instance_link_and_accepts_array_result
    controller = Controller.new
    controller.active_scaffold_config.duplicate.link = Link.new(:can_duplicate?)
    controller.authorization = [true, 'allowed']

    assert_nil controller.duplicate_authorized_filter
  end

  def test_authorization_filter_raises_when_default_link_is_denied
    controller = Controller.new
    controller.authorization = false

    assert_raises(ActiveScaffold::ActionNotAllowed) { controller.duplicate_authorized_filter }
  end

  def test_formats_merge_defaults_core_and_duplicate_formats
    controller = Controller.new

    assert_equal %i[html js xml json], controller.duplicate_formats
  end
end
# rubocop:enable Rails/RefuteMethods
