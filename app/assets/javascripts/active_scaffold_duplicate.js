(function() {
  jQuery(document).ready(function () {
    jQuery(document).on('ajax:beforeSend', '.sub-form-record .actions .dup', function (e, xhr, settings) {
      if (e.detail && !xhr) {
        xhr = e.detail[0];
        settings = e.detail[1];
      }
      var link = jQuery(e.target), row = link.closest('.sub-form-record'), subform = row.closest('.sub-form'),
        url = subform.find('.as_create_another:last').attr('href');
      if (url) {
        var params = {};
        row.find(':input[name]').serializeArray().forEach(function(item) {
          var newName = item.name.replace(/^record\[/, 'dup[');
          params[newName] = item.value;
        });
        var paramString = jQuery.param(params);
        // If URL already has ?, append with & otherwise with ?
        settings.url = url + (url.indexOf('?') !== -1 ? '&' : '?') + paramString;
      } else {
        e.preventDefault();
        return false;
      }
    });

    ActiveScaffold.setup_callbacks.push(function(container) {
      var container = jQuery(container), new_row_subform;
      if (container.is('.sub-form-record')) { // adding a new row to a subform
        new_row_subform = container.closest('.sub-form');
        if (!new_row_subform.is(':has(.as_create_another)')) return;
      }
      jQuery('.sub-form:has(.as_create_another)', container).add(new_row_subform).each(function () {
        var subform = this;
        jQuery('.sub-form-record .actions .dup', this).filter(function () {
          return $(this).closest('.sub-form').is(subform);
        }).show();
      });
    });
  });
})();