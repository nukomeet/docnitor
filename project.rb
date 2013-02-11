require 'date'

class Project
  attr_accessor :name, :total, :payment_on, :payed_on
  
  def initialize(name, total, payment_on, payed_on)
    @name = name
    @total = total
    @payment_on = Date.parse(payment_on) rescue nil
    @payed_on = Date.parse(payed_on) rescue nil
  end
  
  def self.find_not_estimated
    found = []
    ObjectSpace.each_object(self) do |o|
      found << o if o.total.empty?
    end
    found
  end
  
  def self.find_not_scheduled
    found = []
    ObjectSpace.each_object(self) do |o|
      found << o if o.payment_on.to_s.empty?
    end
    found
  end
  
  def self.find_waiting_for_payments
    found = []
    ObjectSpace.each_object(self) do |o|
      found << o if (o.payment_on.nil? ? false : o.payment_on > Date.today)
    end
    found
  end
  
  def self.find_overdue
    found = []
    ObjectSpace.each_object(self) do |o|
      found << o if (o.payment_on.nil? ? false : ( o.payment_on < Date.today && o.payed_on.to_s.empty?) )
    end
    found
  end
end
