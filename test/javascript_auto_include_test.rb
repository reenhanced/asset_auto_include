require "#{File.dirname(__FILE__)}/test_helper"

class JavascriptAutoIncludeTest < ActionView::TestCase
  attr_reader :controller

  context "A controller that has a set of related JS files" do
    
    setup do
      @controller = mock("mock controller")
      @controller.expects(:controller_path).returns("foo/bar").at_least_once
      @controller.expects(:action_name).returns("new").at_least_once
      fake_response javascript_auto_include_tags
    end

    should "include any files for the entire controller" do
      assert_select 'script[src$=foo/bar/controller.js]'
    end
    
    should "include any files only for the current action" do
      assert_select 'script[src$=foo/bar/new.js]'
    end
  
    should "include any files also available for the current action" do
      assert_select 'script[src$=foo/bar/new-edit.js]'
    end
  
    should "not include any files for other actions" do
      assert_select 'script[src$=foo/bar/edit.js]', :count => 0
    end
    
  end # A controller that has a set of related JS files
  
  context "A controller that has no JS files" do

    setup do
      @controller = mock("mock controller")
      @controller.expects(:controller_path).returns("baz").at_least_once
      @controller.expects(:action_name).returns("new").at_least_once
      fake_response javascript_auto_include_tags
    end
    
    should "not include any javascript files" do
      assert @response.body.blank?
    end
  end # A controller that has no JS files
  
end


