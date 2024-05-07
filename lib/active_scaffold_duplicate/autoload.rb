module ActiveScaffold
  module Actions
    ActiveScaffold.autoload_subdir('actions', self, ActiveScaffoldDuplicate.root + '/lib')
  end

  module Config
    ActiveScaffold.autoload_subdir('config', self, ActiveScaffoldDuplicate.root + '/lib')
  end

  module Helpers
    ActiveScaffold.autoload_subdir('helpers', self, ActiveScaffoldDuplicate.root + '/lib')
  end
end
