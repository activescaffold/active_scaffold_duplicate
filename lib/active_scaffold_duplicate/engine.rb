module ActiveScaffoldDuplicate
  class Engine < ::Rails::Engine
    initializer "active_scaffold_duplicate.action_view" do |app|
      ActiveSupport.on_load :action_view do
        include ActiveScaffold::Helpers::DuplicateHelpers
      end
    end
    initializer 'active_scaffold_duplicate.routes' do
      ActiveSupport.on_load :active_scaffold_routing do
        self::ACTIVE_SCAFFOLD_CORE_ROUTING[:member][:duplicate] = [:post, :get]
      end
    end
  end
end
