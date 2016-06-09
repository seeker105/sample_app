class GithubService

  def initialize
    @_connection = Faraday.new(url: "https://api.github.com/user")
  end

  def organizations(current_user)
    response = @_connection.get do |req|
      req.url 'orgs'
      req.headers[:Authorization] = "token #{current_user.github_access_token}"
    end
    JSON.parse(response.body)
  end

end
