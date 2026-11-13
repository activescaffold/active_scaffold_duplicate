# frozen_string_literal: true

module ActiveScaffoldDuplicate
  class Engine < ::Rails::Engine
    initializer 'active_scaffold_duplicate.action_view' do |_app|
      ActiveSupport.on_load :action_view do
        include ActiveScaffold::Helpers::DuplicateHelpers
      end
    end
    initializer 'active_scaffold_duplicate.routes' do
      ActiveSupport.on_load :active_scaffold_routing do
        self::ACTIVE_SCAFFOLD_CORE_ROUTING[:member][:duplicate] = %i[post get]
      end
    end
    initializer 'active_scaffold_duplicate.extensions' do
      ActiveScaffold::Actions::Subform.prepend ActiveScaffoldDuplicate::Subform
    end
  end
end
