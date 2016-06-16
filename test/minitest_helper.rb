ENV["RACK_ENV"] ||= "test"

require 'bundler'
Bundler.require

require File.expand_path("../../config/environment", __FILE__)
require 'minitest/autorun'
require 'minitest/pride'
require 'capybara/dsl'
# require 'database_cleaner'
require 'tilt/erb'
require 'pry'



module MinitestHelper

  def site_login(user)
    visit "/login"
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    within "header" do
      click_on "Log in"
    end

    save_and_open_page
  end


  def site_logout
    click_link "Logout"
  end


end
