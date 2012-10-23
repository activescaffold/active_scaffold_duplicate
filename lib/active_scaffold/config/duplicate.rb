module ActiveScaffold::Config
  class Duplicate < Base
    self.crud_type = :create
    
    def initialize(core_config)
      @core = core_config
      self.method = self.class.method
      self.link = self.class.link.clone
      self.action_after_clone = self.class.action_after_clone
      self.refresh_list = self.class.refresh_list
    end

    # the method to clone records
    cattr_accessor :method
    @@method = :dup
    
    # which action render after clone
    cattr_accessor :action_after_clone
    @@action_after_clone = nil

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

    # which action render after clone
    attr_accessor :action_after_clone

    # whether we should refresh list after clone or not
    attr_accessor :refresh_list
  end
end
