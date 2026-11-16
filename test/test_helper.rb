# frozen_string_literal: true

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start
end
require 'minitest/autorun'
require 'rails'
require 'action_view'
require 'active_support/core_ext/module/attribute_accessors_per_thread'
require 'active_scaffold'
require 'active_scaffold_duplicate'
