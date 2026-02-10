# Duplicate Action for ActiveScaffold

Currently, this gem is compatible with ActiveScaffold >= 4.2.0

## Overview

This gem adds an action to clone records. By default will only set attributes and belongs_to associations. You must override `initialize_dup` in your model or define a method to clone the record and set in `conf.duplicate.method`.

Also, adds support to duplicate rows in a subform, setting the `:duplicate` setting in the column's options, or `form_ui_options`.

## Installation

You'll need at least ActiveScaffold 3.3.x to use this, and rails 3.x

```bash
gem install active_scaffold_duplicate
```

## Usage

#### Step 1

Override `initialize_dup` in the model to set some attributes or copy associations:

```ruby
# app/models/bill.rb
class Bill < ActiveRecord::Base
  belongs_to :customer
  has_many :items
  
  def initialize_dup(other)
    super
    self.items = other.items.map(&:dup)
  end
end
```

#### Step 2

Add duplicate action.

```ruby
class BillsController < ApplicationController
  active_scaffold do |conf|
    conf.actions << :duplicate
  end
end
```

#### Step 3

Change method to `:get` in link if you want to display create form instead of cloning record. Set position to `:replace` or `:after` for inline display, or enable page rendering.

```ruby
class BillsController < ApplicationController
  active_scaffold do |conf|
    conf.duplicate.link.method = :get
    conf.duplicate.link.position = :after
    #conf.duplicate.link.page = true # for new page rendering
  end
end
```

Also you can change it globally.

```ruby
class ApplicationController < ActionController::Base
  active_scaffold.set_defaults do |conf|
    conf.duplicate.link.method = :get
    conf.duplicate.link.position = :after
    #conf.duplicate.link.page = true # for new page rendering
  end
end
```

You can access to record which is being duplicated in your form overrides with `@old_record` variable.

If you use `:post` method, you can enable `refresh_list` to refresh the list instead of only adding new record at top, or set `action_after_clone` to open edit form for example:

```ruby
  conf.duplicate.refresh_list = true
  conf.duplicate.action_after_clone = :edit
```

## Before/after controller methods

It's possible to define some methods to add some custom code which require access to session or request params:

* For `:post` method, `before_duplicate_save(record)` and `after_duplicate_save(record)` can be defined, which will be called before and after saving the record respectively.
* For `:new` method, `before_duplicate_new(record)` can be defined, which will be called before rendering.

## Duplicate record in subforms

Set the `:duplicate` setting in the column's options, or `form_ui_options`.

```ruby
conf.columns[:lines].form_ui = nil, {duplicate: true} # set in the options for form_ui only, leaving UI as nil so subform is used
conf.columns[:lines].options = {duplicate: true} # set in the column options, would be available to other UI (list, show, search), although won't affect probably
```

Cloning the record will send a request to `edit_associated` action in the parent controller, same as adding a new record.

If you want to make changes to the cloned record before added to the subform, you can override `duplicate_subform_record` method in your controller, call `super` to leave active_scaffold_duplicate to copy the submitted attributes, and then make your changes. You can check what subform was called for with `@column` variable:

```ruby
  def duplicate_subform_row(record, ...)
    super
    if @column == :travel_line_items
      record.financial_month = nil # don't copy financial month
      record.compute_totals
    end
  end
```

## Support

If you have issues installing the gem, search / post to the [Active Scaffold](http://groups.google.com/group/activescaffold) forum or [Create an issue](http://github.com/activescaffold/active_scaffold_duplicate/issues)

## Contributing

Fork, hack, push, and request a pull:

<http://github.com/activescaffold/active_scaffold_duplicate/>

## License

Released under the MIT license (included).

## Author

Contact me:

```ruby
  Sergio Cambra - irb(main):001:0> ( 'sergioATenpijama._see_s'.gsub('_see_', 'e').gsub('AT', '@') )
```
