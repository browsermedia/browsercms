module FixtureReplacement

  attributes_for :connector do |a|
    a.page = default_page
    a.page_version = 1
    a.container = "main"
    a.content_block = default_html_block
	end

  attributes_for :content_type do |a|
    a.name = "Test"
  end

  attributes_for :file_binary_data do |a|
  end

  attributes_for :file_block do |a|
    a.updated_by_user = default_user    
  end

  attributes_for :file_metadata do |a|
    a.file_binary_data = default_file_binary_data
  end

  attributes_for :group do |a|
    a.name = "TestGroup#{Sequence.next}"
  end

  attributes_for :html_block do |a|
    a.name = "About Us"
    a.content = "<h1>About Us</h1>\n<p>Lorem ipsum dolor sit amet...</p>"
    a.updated_by_user = default_user
	end

  attributes_for :image_block do |a|
    a.name = "Sample Image"
    a.updated_by_user = default_user
  end

  attributes_for :page do |a|
    a.name = "Home #{Sequence.next}"
    a.path = "/#{a.name.gsub(/\s/,'_').downcase}"
    a.template = default_page_template
    a.section = default_section
    a.updated_by_user = default_user
    a.version = 1
	end

  attributes_for :page_template do |a|
    a.name = "Foo"
    a.file_name = "foo"
  end

  attributes_for :permission do |a|
    a.name = "TestPermission#{Sequence.next}"
  end

  attributes_for :portlet do |a|
    a.name = "Find X"
    a.portlet_type = default_portlet_type
  end

  attributes_for :portlet_type do |a|
    a.name = "Find Stuff"
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

  attributes_for :link do |a|
    a.name = "Test"
    a.url = "http://www.example.com"
    a.updated_by_user = default_user
  end

end