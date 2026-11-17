# frozen_string_literal: true

require 'javascript_test_helper'

class DuplicateJavascriptTest < ActiveScaffold::TestSupport::Javascript::TestCase
  def fixture_html
    <<~HTML
      <div class="active-scaffold">
        <div class="sub-form">
          <a class="as_create_another" href="/records/new?parent=5">Create another</a>
          <div class="sub-form-record">
            <input name="record[name]" value="Example">
            <input name="record[enabled]" value="1">
            <div class="actions"><a id="duplicate-link" class="dup" style="display:none" href="/duplicate">Duplicate</a></div>
          </div>
        </div>
      </div>
    HTML
  end

  def test_enables_duplicate_link_and_builds_request_from_row_fields
    visit_javascript_fixture

    assert_javascript 'document.querySelector("#duplicate-link").style.display !== "none"'
    execute_script <<~JS
      window.duplicateSettings = {url: '/duplicate'};
      jQuery('#duplicate-link').trigger('ajax:beforeSend', [{}, window.duplicateSettings]);
    JS

    assert_javascript <<~JS
      (function() {
        var url = new URL(window.duplicateSettings.url, window.location.origin);
        return url.pathname === '/records/new' && url.searchParams.get('parent') === '5' &&
          url.searchParams.get('dup[name]') === 'Example' && url.searchParams.get('dup[enabled]') === '1';
      })()
    JS
    assert_no_javascript_errors
  end
end
