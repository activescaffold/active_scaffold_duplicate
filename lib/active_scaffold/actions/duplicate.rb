module ActiveScaffold::Actions
  module Duplicate
    def self.included(base)
      base.before_action :duplicate_authorized_filter, :only => :duplicate
    end
    
    def duplicate
      @old_record = find_if_allowed(params[:id], :read)
      @record = @old_record.send(active_scaffold_config.duplicate.method)
      if request.post?
        before_duplicate_save(@record)
        self.successful = @record.save
        after_duplicate_save(@record) if successful?
        respond_to_action(:duplicate)
      else
        params.delete :id
        before_duplicate_new(@record)
        respond_to_action(active_scaffold_config.duplicate.action_view)
      end
    end
    
    protected
    def before_duplicate_save(record); end
    def before_duplicate_new(record); end
    def after_duplicate_save(record); end

    def duplicate_authorized?(record = nil)
      (record || self).authorized_for?(crud_type: :create, action: :duplicate, reason: true)
    end
    
    def duplicate_respond_to_html
      if successful?
        flash[:info] = as_(:created_model, :model => @record.to_label)
        if action = active_scaffold_config.duplicate.action_after_clone
          redirect_to params_for(:action => action, :id => @record.id)
        else
          return_to_main
        end
      else
        return_to_main
      end
    end
    
    def duplicate_respond_to_js
      do_refresh_list if successful? && active_scaffold_config.duplicate.refresh_list
      render :action => 'duplicate'
    end

    def duplicate_respond_to_xml
      render :xml => response_object.to_xml(:only => active_scaffold_config.create.columns.visible_columns_names), :content_type => Mime::XML, :status => response_status, :location => response_location
    end

    def duplicate_respond_to_json
      render :text => response_object.to_json(:only => active_scaffold_config.create.columns.visible_columns_names), :content_type => Mime::JSON, :status => response_status, :location => response_location
    end

    def duplicate_respond_to_yaml
      render :text => Hash.from_xml(response_object.to_xml(:only => active_scaffold_config.create.columns.visible_columns_names)).to_yaml, :content_type => Mime::YAML, :status => response_status, :location => response_location
    end
    
    private
    def duplicate_authorized_filter
      link = active_scaffold_config.duplicate.link || active_scaffold_config.duplicate.class.link
      raise ActiveScaffold::ActionNotAllowed unless Array(send(link.security_method))[0]
    end
    def duplicate_formats
      (default_formats + active_scaffold_config.formats + active_scaffold_config.duplicate.formats).uniq
    end
  end
end
