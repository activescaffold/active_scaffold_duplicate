module ActiveScaffoldDuplicate
  class Engine < ::Rails::Engine
    initializer "active_scaffold.action_view" do |app|
      ActiveSupport.on_load :action_view do
        include ActiveScaffold::Helpers::DuplicateHelpers
      end
    end
  end
end
