require "cuba"
require "cuba/sugar/as"
require "cuba/render"
require "httparty"
require "json"
require "google_drive"
require "hipchat"
require "./project.rb"
require "tilt"
require "slim"
require "rack/env"

Cuba.plugin Cuba::Sugar::As
Cuba.plugin Cuba::Render

Cuba.define do
  on get do
    on root do
      client = HipChat::Client.new(ENV['HIPCHAT_TOKEN'])
      session = GoogleDrive.login(ENV['G_USERNAME'], ENV['G_PASSWORD'])
      ws = session.spreadsheet_by_key(ENV['SHEET_KEY']).worksheets[3]
            
      for row in 3..ws.num_rows
        name, total, payment_on, payed_on = ws[row, 1], ws[row, 2], ws[row, 8], ws[row, 9]
        unless name.empty? && total.empty? && payment_on.empty? && payed_on.empty?
          Project.new(name, total, payment_on, payed_on)
        end
      end
      
      def color(elements, color)
        'green' if elements == 0
        color if elements != 0
      end
      
      client['nukomeetment'].send('Docnitor', render("messages/overdue.slim", projects: Project.find_overdue), :color => color(Project.find_overdue.count, 'red'))
      
      client['nukomeetment'].send('Docnitor', render("messages/not_estimated.slim", projects: Project.find_not_estimated), :color => color(Project.find_not_estimated.count, 'red'))
      
      client['nukomeetment'].send('Docnitor', render("messages/not_scheduled.slim", projects: Project.find_not_scheduled), :color => color(Project.find_not_scheduled.count, 'red'))
      
      client['nukomeetment'].send('Docnitor', render("messages/waiting_for_payments.slim", projects: Project.find_waiting_for_payments), :color =>  color(Project.find_waiting_for_payments.count, 'yellow'))
    
      res.write "ok"
      ObjectSpace.garbage_collect
    end
  end
end
