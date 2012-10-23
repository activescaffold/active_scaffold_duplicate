module ActiveScaffold::Actions
  module Duplicate
    def self.included(base)
      base.before_filter :duplicate_authorized_filter, :only => :duplicate
    end
    
    def duplicate
      old_record = find_if_allowed(params[:id], :read)
      @record = old_record.send(active_scaffold_config.duplicate.method)
      if request.post?
        self.successful = @record.save
        respond_to_action(:duplicate)
      else
        respond_to_action(:new)
      end
    end
    
    protected
    def duplicate_authorized?(record = nil)
      (record || self).authorized_for?(:crud_type => :create, :action => :duplicate)
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
      render :xml => response_object.to_xml(:only => active_scaffold_config.create.columns.names), :content_type => Mime::XML, :status => response_status, :location => response_location
    end

    def duplicate_respond_to_json
      render :text => response_object.to_json(:only => active_scaffold_config.create.columns.names), :content_type => Mime::JSON, :status => response_status, :location => response_location
    end

    def duplicate_respond_to_yaml
      render :text => Hash.from_xml(response_object.to_xml(:only => active_scaffold_config.create.columns.names)).to_yaml, :content_type => Mime::YAML, :status => response_status, :location => response_location
    end
    
    private
    def duplicate_authorized_filter
      link = active_scaffold_config.duplicate.link || active_scaffold_config.duplicate.class.link
      raise ActiveScaffold::ActionNotAllowed unless self.send(link.security_method)
    end
    def duplicate_formats
      (default_formats + active_scaffold_config.formats + active_scaffold_config.duplicate.formats).uniq
    end
  end
end
