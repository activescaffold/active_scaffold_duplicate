# frozen_string_literal: true

module ActiveScaffoldDuplicate
  module Subform
    protected

    def do_edit_associated
      super
      return unless params[:dup]

      attributes = params.delete(:dup)
      @scope[1..-2]&.split('][')&.each { |scope| attributes = attributes[scope] } if @scope
      attributes = attributes[@column.name].values[0]
      duplicate_subform_row(@record, attributes)
    end

    def duplicate_subform_row(record, attributes, columns = nil)
      cfg = active_scaffold_config_for(record.class) unless columns
      update_record_from_params(record, columns || cfg.subform.columns, attributes, avoid_changes: true)
    end
  end
end
