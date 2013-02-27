# encoding: UTF-8
require_relative '../docnitor'
require 'slim'
require 'tilt'
require 'date'

describe "Docnitor messages" do
    before :all do
        @not_estimated = [{ 'name' => 'Test', 'total' => '', 'payment_on' => Date.today + 1, 'payed_on' => nil }]
        @not_scheduled = [{ 'name' => 'Test', 'total' => '1000', 'payment_on' => nil, 'payed_on' => nil }]
        @waiting_for_payments = [{ 'name' => 'Test', 'total' => '1000', 'payment_on' => Date.today + 1, 'payed_on' => nil }]
        @overdue = [{ 'name' => 'Test', 'total' => '1000', 'payment_on' => Date.today - 1, 'payed_on' => nil }]
    end

    describe "waiting_for_payment message" do
       template = Tilt.new('./messages/waiting_for_payments.slim')
       it "renders proper data" do
           str = "<b>Projects waiting for payment: 1</b><br />1 Test 1000€ in 1 day(s)<br />"
           template.render("messages/waiting_for_payments.slim", projects: @waiting_for_payments).should eql str
       end
    end

    describe "not_estimated message" do
        template = Tilt.new('./messages/not_estimated.slim')
        it "renders proper data" do
            str = "<b>Projects waiting for payment estimation: 1</b><br />1 Test<br />"
            template.render("messages/not_estimated.slim", projects: @not_estimated).should eql str
        end
    end

    describe "not_scheduled message" do
        template = Tilt.new('./messages/not_scheduled.slim')
        it "renders proper data" do
            str = "<b>Projects with no scheduled payments: 1</b><br />1 Test 1000€<br />"
            template.render("messages/not_scheduled.slim", projects: @not_scheduled).should eql str
        end
    end

    describe "overdue message" do
        template = Tilt.new('./messages/overdue.slim')
        it "renders proper data" do
            str = "<b>Payment overdue projects: 1</b><br />1 Test 1000€ for 1 day(s)<br />"
            template.render("messages/overdue.slim", projects: @overdue).should eql str
        end
    end
end
