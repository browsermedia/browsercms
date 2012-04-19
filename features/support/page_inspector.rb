module PageInspector

  # Fetch an image from page and make sure it exists.
  def get_image(css_selector)
    assert page.has_css?(css_selector)
    img_tag = page.first(:css, css_selector)
    visit img_tag[:src]
    assert_equal 200, page.status_code
  end

  def page_should_have_content(content, should_be_true=true)
    if should_be_true
      assert page.has_content?(content), "Couldn't find #{content}' anywhere on the page."
    else
      assert !page.has_content?(content), "Found #{content}' on the page when it was not expected to be there."
    end
  end
end
World(PageInspector)