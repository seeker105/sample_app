class GithubService

  def initialize
    @_connection = Faraday.new(url: "https://api.github.com/user")
  end

  def organizations(current_user)
    organizations = @_connection.get("/orgs") do |req|
      req.headers[:Authorization] = "token #{current_user.github_access_token}"
    end
    byebug
    parsed_orgs = JSON.parse(organizations)
  end

end
