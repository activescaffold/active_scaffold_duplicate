module ActiveScaffoldDuplicate
  module Subform
    protected
    def do_edit_associated
      super
      if params[:dup]
        attributes = params.delete(:dup)
        @scope&.slice(1..-2)&.split('][')&.each { |scope| attributes = attributes[scope] }
        attributes = attributes[@column.name].values[0]
        duplicate_subform_row(@record, attributes)
      end
    end

    def duplicate_subform_row(record, attributes, columns = nil)
      cfg = active_scaffold_config_for(record.class) unless columns
      update_record_from_params(record, columns || cfg.subform.columns, attributes, true)
    end
  end
end
