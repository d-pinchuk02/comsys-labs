#!/usr/bin/env ruby

require "./formatter"
require "./tokenizer"
require "./validator"

input = File.read("input.txt")

tokenizer = Tokenizer.new(input)
tokens = tokenizer.tokenize
tokenizer_errors = tokenizer.errors

validator = Validator.new(tokens)
validator_errors = validator.validate

errors = tokenizer_errors + validator_errors

puts "ПЗКС - Лабораторна робота №1".cyan.bold
puts "-" * 50
puts "Аналіз виразу: #{input.gray}".cyan.bold
puts "-" * 50

print "Токени: ".cyan.bold
tokens.each do |token|
  print "#{token.type.to_s.green.bold}(#{token.value.to_s.bold}) "
end
puts ""
puts "-" * 50

if errors.empty?
  puts "\nВираз правильний.".green.bold
else
  puts "Знайдені помилки:".cyan.bold
  errors.each do |error|
    pointer = " " * error.position + "^".red.bold
    puts "\n#{input}\n#{pointer}"
    puts "#{error.message.red.bold}"
  end

  puts "\nВираз містить помилки (#{errors.length})!".underline.bold
end
