module FixtureReplacement

  attributes_for :attachment do |a|
    a.attachment_file = default_attachment_file
  end

  attributes_for :attachment_file do |a|
  end

  attributes_for :category do |a|
    a.category_type = default_category_type
    a.name = "TestCategory#{Sequence.next}"
  end

  attributes_for :category_type do |a|
    a.name = "TestCategoryType#{Sequence.next}"
  end

  attributes_for :connector do |a|
    a.page = default_page
    a.page_version = 1
    a.container = "main"
    a.connectable = default_html_block
    a.connectable_version = 1
	end

  attributes_for :content_type do |a|
    a.name = "Test"
    a.content_type_group = default_content_type_group
  end

  attributes_for :content_type_group do |a|
    a.name = "TestContentTypeGroup#{Sequence.next}"
  end

  attributes_for :dynamic_portlet do |a|
    a.name = "Find X"
  end

  attributes_for :file_block do |a|
    a.name = "TestFileBlock#{Sequence.next}"
    #a.attachment_file_name = "#{a.name.to_slug}.pdf"  
  end

  attributes_for :group do |a|
    a.name = "TestGroup#{Sequence.next}"
  end

  attributes_for :group_type do |a|
    a.name = "TestGroupType#{Sequence.next}"
  end

  attributes_for :html_block do |a|
    a.name = "About Us"
    a.content = "<h1>About Us</h1>\n<p>Lorem ipsum dolor sit amet...</p>"
	end

  attributes_for :image_block do |a|
    a.name = "TestImageBlock#{Sequence.next}"
    a.attachment_file_name = "#{a.name.to_slug}.jpg"
  end

  attributes_for :link do |a|
    a.name = "ExampleLink#{Sequence.next}"
    a.url = "http://www.example#{Sequence.next}.com"
  end

  attributes_for :page do |a|
    a.name = "Page #{Sequence.next}"
    a.path = "/#{a.name.gsub(/\s/,'_').downcase}"
    a.template = default_page_template
    a.section = default_section
	end

  attributes_for :page_template do |a|
    a.name = "Foo"
    a.file_name = "foo"
    a.language = "erb"
  end

  attributes_for :permission do |a|
    a.name = "TestPermission#{Sequence.next}"
  end
  
  attributes_for :redirect do |a|
    a.from_path = "/from#{Sequence.next}"
    a.to_path = "/to#{Sequence.next}"
  end
  
  attributes_for :section do |a|
    a.name = "Test"
    a.path = "/"
  end

  attributes_for :section_node do |a|
    a.section = default_section
    a.node = default_page  
  end

  attributes_for :site do |a|
    a.name = "Test #{Sequence.next}"
    a.domain = "#{a.name.gsub(/\s/,"_").downcase}.com"
  end

  attributes_for :user do |a|
    a.first_name = "Test"
    a.last_name = "User"
    a.login = "test_#{Sequence.next}"
    a.email = "#{a.login}@example.com"
    a.password = a.password_confirmation = "password"
    a.created_at = 5.days.ago
  end

end