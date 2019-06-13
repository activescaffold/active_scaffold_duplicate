module ActiveScaffold::Config
  class Duplicate < Base
    self.crud_type = :create
    
    def initialize(core_config)
      super
      self.method = self.class.method
      self.action_after_clone = self.class.action_after_clone
      self.action_view = self.class.action_view
      self.refresh_list = self.class.refresh_list
    end

    # the method to clone records
    cattr_accessor :method
    @@method = :dup
    
    # which action render after clone with post
    cattr_accessor :action_after_clone
    @@action_after_clone = nil

    # which view render when method is :get (used as respond_to_action argument)
    cattr_accessor :action_view
    @@action_view = :new

    # whether we should refresh list after clone or not
    cattr_accessor :refresh_list
    @@refresh_list = false

    # the ActionLink for this action
    cattr_accessor :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new(:duplicate, :type => :member, :method => :post, :position => false, :security_method => :duplicate_authorized?, :ignore_method => :duplicate_ignore?)

    # instance-level configuration
    # ----------------------------

    # the ActionLink for this action
    attr_accessor :link
    
    # the method to clone records
    attr_accessor :method

    # which action render after clone with post
    attr_accessor :action_after_clone

    # which view render when method is :get (used as respond_to_action argument)
    attr_accessor :action_view

    # whether we should refresh list after clone or not
    attr_accessor :refresh_list

    UserSettings.class_eval do
      user_attr :method, :action_after_clone, :action_view, :refresh_list
    end
  end
end
