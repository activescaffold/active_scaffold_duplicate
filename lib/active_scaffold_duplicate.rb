# frozen_string_literal: true

require 'active_scaffold_duplicate/engine'
require 'active_scaffold_duplicate/extensions'

module ActiveScaffoldDuplicate
  def self.root
    "#{File.dirname(__FILE__)}/.."
  end
  autoload :Subform, 'active_scaffold_duplicate/subform'
end

ActiveScaffold.javascripts << 'active_scaffold_duplicate'
