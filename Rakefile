require "httparty"

task :present do
  response = HTTParty.get('http://docnitor.herokuapp.com', :basic_auth => { :username => ENV['AUTH_USERNAME'], :password => ENV['AUTH_PASSWORD'] })
  puts response.code
end
