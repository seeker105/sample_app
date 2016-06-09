class AddGithubAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_access_token, :text
  end
end
