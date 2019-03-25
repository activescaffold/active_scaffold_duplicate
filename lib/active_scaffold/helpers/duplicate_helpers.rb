module ActiveScaffold
  module Helpers
    module DuplicateHelpers
      def current_form_columns(record, scope, subform_controller = nil)
        columns = super
        if columns.nil? && action_name == 'duplicate'
          active_scaffold_config.create.columns.visible_columns_names
        else
          columns
        end
      end
    end
  end
end
