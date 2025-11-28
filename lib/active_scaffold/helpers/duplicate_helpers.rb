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

      def active_scaffold_subform_record_actions(association_column, record, locked, scope)
        actions = super
        return actions unless association_column.association.collection?
        return actions unless (association_column.form_ui_options || association_column.options)[:duplicate]

        safe_join(
          [
            link_to(as_(:duplicate), '#', class: 'dup', style: 'display: none;', remote: true, data: {scope: scope}),
            actions
          ]
        )
      end
    end
  end
end
