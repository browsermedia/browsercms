require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'fixtures/author')
require File.join(File.dirname(__FILE__), 'fixtures/page')

class VersionFuTest < Test::Unit::TestCase
  fixtures :pages, :page_versions, :authors, :author_versions
  set_fixture_class :page_versions => Page::Version
  set_fixture_class :author_versions => Author::Version
  
  #############################################################################
  #                         A S S O C I A T I O N S                           #
  #############################################################################           
  def test_parent_has_many_version
    assert_equal page_versions(:welcome_1, :welcome_2), pages(:welcome).versions 
  end
  
  def test_version_belongs_to_parent
    assert_equal pages(:welcome), page_versions(:welcome_1).page
  end
  
  #############################################################################
  #                              A T T R I B U T E S                          #
  #############################################################################
  def test_should_version_proper_attributes
    assert_equal ['title', 'body', 'author_id'], Page.new.versioned_columns
  end
  
  def test_should_not_version_non_existing_column
    assert !Page.new.versioned_columns.include?(:creator_id)
  end
  
  #############################################################################
  #                               C R E A T E                                 #
  #############################################################################
  def test_should_save_version_on_create
    old_count = Page.count
    old_version_count = Page::Version.count
    page = Page.create :title=>'New', :body=>'body', :creator=>authors(:larry), :author=>authors(:larry)
    assert_equal old_count + 1, Page.count
    assert_equal old_version_count + 1, Page::Version.count
  end
  
  def test_wire_up_association_on_create
    page = Page.create :title=>'New', :body=>'body', :creator=>authors(:larry), :author=>authors(:larry)
    assert_equal Page::Version.find(:first, :order=>'id desc'), page.versions.first
  end
  
  def test_begin_version_numbering_at_one
    page = Page.create :title=>'New', :body=>'body', :creator=>authors(:larry), :author=>authors(:larry)
    assert_equal 1, page.version
    assert_equal 1, page.versions.first.version
  end
  
  def test_assigns_attributes_on_create
    page = Page.create :title=>'New', :body=>'body', :creator=>authors(:larry), :author=>authors(:larry)
    version = page.versions.first
    assert_equal 'New', version.title
    assert_equal 'body', version.body
    assert_equal authors(:larry).id, version.author_id
  end
  
  #############################################################################
  #                                   U P D A T E                             #
  #############################################################################
  def test_should_save_version_on_update
    old_count = Page::Version.count
    page = pages(:welcome)
    page.update_attributes :title=>'New title', :body=>'new body', :author=>authors(:sara)
    assert_equal old_count + 1, Page::Version.count
  end
  
  def test_should_increment_version_number
    page = pages(:welcome)
    old_count = page.version
    page.update_attributes :title=>'New title', :body=>'new body', :author=>authors(:sara)
    assert_equal old_count + 1, page.reload.version
  end
  
  def test_update_version_attributes
    page = pages(:welcome)
    page.update_attributes :title=>'Latest', :body=>'newest', :author=>authors(:peter)
    version = page.reload.versions.latest
    assert_equal 'Latest', version.title
    assert_equal 'newest', version.body
    assert_equal authors(:peter).id, version.author_id
  end
  
  #############################################################################
  #                         S K I P    V E R S I O N I N G                    #
  #############################################################################
  def test_do_not_create_version_if_nothing_changed
    old_count = Page::Version.count
    pages(:welcome).save
    assert_equal old_count, Page::Version.count
  end  
  
  def test_do_not_create_version_if_untracked_attribute_changed
    old_count = Page::Version.count
    pages(:welcome).update_attributes :author=>authors(:sara)
    assert_equal old_count, Page::Version.count
  end
    
  def test_do_not_create_version_if_custom_version_check
    old_count = Author::Version.count
    authors(:larry).update_attributes :last_name=>'Lessig'
    assert_equal old_count, Author::Version.count
  end

  def test_still_save_if_no_new_version_with_custom_version_check
    authors(:larry).update_attributes :last_name=>'Lessig'
    assert_equal 'Lessig', authors(:larry).reload.last_name
  end
  
  #############################################################################
  #                                 F I N D                                   #
  #############################################################################
  def test_find_version_given_number
    assert_equal page_versions(:welcome_1), pages(:welcome).find_version(1)
    assert_equal page_versions(:welcome_2), pages(:welcome).find_version(2)
  end
  
  def test_find_latest_version
    assert_equal page_versions(:welcome_2), pages(:welcome).versions.latest
  end
  
  def test_find_previous_version
    assert_equal page_versions(:welcome_1), page_versions(:welcome_2).previous
  end
  
  def test_find_next_version
     assert_equal page_versions(:welcome_2), page_versions(:welcome_1).next
  end
  
  #############################################################################
  #                        B L O C K    E X T E N S I O N                     #
  #############################################################################
  def test_should_take_a_block_containing_ar_extention
    assert_equal authors(:larry), page_versions(:welcome_1).author
  end
end