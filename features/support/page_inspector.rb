# Support for inspecting the result of pages
module PageInspector

  # Fetch an image from page and make sure it exists.
  def get_image(css_selector)
    assert page.has_css?(css_selector)
    img_tag = page.first(:css, css_selector)
    visit img_tag[:src]
    assert_equal 200, page.status_code
  end

  # Adds better page content assertions (Rspec like)
  def page_should_have_content(content, should_be_true=true)
    if should_be_true
      assert page.has_content?(content), "Couldn't find #{content}' anywhere on the page."
    else
      assert !page.has_content?(content), "Found #{content}' on the page when it was not expected to be there."
    end
  end

  def should_see_a_page_header(page_header)
    message = "Expected find <h1>#{page_header}'</h1>."
    assert page.has_css?("h1", :text => page_header), failure_message(message) { " Found instead <h1>#{find('h1').text}</h1>."}
  end

  def failure_message(message)
    if block_given?
      message << yield
    end
    message
  end
  # Both <H1> and <title> should match.
  def should_see_a_page_named(page_title)
    should_see_a_page_header(page_title)
    should_see_a_page_titled(page_title)
  end

  def should_see_a_page_titled(page_title)
    assert page.has_title?(page_title), "Expected a page with a title '#{page_title}' but it was '#{page.title}'."
  end

  def should_see_cms_404_page
    should_see_a_page_named "Page Not Found"
    assert_equal 404, page.status_code
    assert page.has_content?("Page Not Found")
  end

  def should_be_successful
    assert_equal 200, page.status_code, "While on page #{current_url}"
  end

end
World(PageInspector)