require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
  end

  test "signup page" do
    get signup_path
    page.has_text?("Sign up")
  end

  test "signup page full title" do
    get signup_path
    assert_select "title", full_title("Sign up")
  end

  test "full title helper" do
    assert_equal full_title,         "Ruby on Rails Tutorial"
    assert_equal full_title("Help"), "Help | Ruby on Rails Tutorial"
  end
end
