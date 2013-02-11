require "httparty"

task :present do
  response = HTTParty.get('http://docnitor.herokuapp.com')
  puts response.code
end
