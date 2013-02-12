require "cuba"
require "cuba/sugar/as"
require "cuba/render"
require "httparty"
require "json"
require "google_drive"
require "hipchat"
require "tilt"
require "slim"
require "rack/env"

Cuba.plugin Cuba::Sugar::As
Cuba.plugin Cuba::Render
Cuba.use Rack::Env

Cuba.use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']]
end

Cuba.define do
  on get do
    on root do
      client = HipChat::Client.new(ENV['HIPCHAT_TOKEN'])
      session = GoogleDrive.login(ENV['G_USERNAME'], ENV['G_PASSWORD'])
      ws = session.spreadsheet_by_key(ENV['SHEET_KEY']).worksheets[3]
      
      projects = []
            
      for row in 3..ws.num_rows
        name, total, payment_on, payed_on = ws[row, 1], ws[row, 2], ws[row, 8], ws[row, 9]
        unless name.empty? && total.empty? && payment_on.empty? && payed_on.empty?
          projects << project = {'name' => name, 'total' => total, 'payment_on' => (Date.parse(payment_on) rescue nil), 'payed_on' => (Date.parse(payed_on) rescue nil)}
        end
      end
      
      not_estimated, not_scheduled, waiting_for_payments, overdue = [], [], [], []
    
      projects.each do |project|
        not_estimated << project if project['total'].empty?
        not_scheduled << project if project['payment_on'].nil?
        waiting_for_payments << project if (project['payment_on'].nil? ? false : project['payment_on'] > Date.today)
        overdue << project if (project['payment_on'].nil? ? false : (project['payment_on'] < Date.today && project['payed_on'].nil?))
      end
      
      def color(elements, color)
        'green' if elements == 0
        color if elements != 0
      end
      
      client['nukomeetment'].send('Docnitor', render("messages/overdue.slim", projects: overdue), :color => color(overdue.count, 'red'))
      client['nukomeetment'].send('Docnitor', render("messages/not_estimated.slim", projects: not_estimated), :color => color(not_estimated.count, 'red'))
      client['nukomeetment'].send('Docnitor', render("messages/not_scheduled.slim", projects: not_scheduled), :color => color(not_scheduled.count, 'red'))
      client['nukomeetment'].send('Docnitor', render("messages/waiting_for_payments.slim", projects: waiting_for_payments), :color =>  color(waiting_for_payments.count, 'yellow'))
      
      res.write "OK"
    end
  end
end
