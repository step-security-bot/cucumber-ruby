begin
  require 'rspec/expectations'
rescue LoadError
  require 'spec/expectations'
end

require 'cucumber/formatter/unicode'
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'calcolatrice'

Before do
  @calc = Calcolatrice.new
end

After do
end

Given(/che ho inserito (\d+)/) do |n|
  @calc.push n.to_i
end

When('premo somma') do
  @result = @calc.add
end

Then(/il risultato deve essere (\d*)/) do |result|
  expect(@result).to eq(result.to_i)
end
