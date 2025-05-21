#!/usr/bin/env ruby

require "../lab1/formatter"
require "../lab1/tokenizer"
require "../lab1/validator"
require "./optimizer"

input = File.read("input.txt")

tokenizer = Tokenizer.new(input)
tokens = tokenizer.tokenize
tokenizer_errors = tokenizer.errors

validator = Validator.new(tokens)
validator_errors = validator.validate

errors = tokenizer_errors + validator_errors

puts "ПЗКС - Лабораторна робота №2".cyan.bold
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
  puts "Вираз правильний.".green.bold

  optimizer = Optimizer.new(tokens)
  optimized_tokens, changes = optimizer.optimize

  puts "-" * 50
  print "Оптимізовані токени: ".cyan.bold
  optimized_tokens.each do |token|
    print "#{token.type.to_s.green.bold}(#{token.value.to_s.bold}) "
  end
  puts ""
  puts "-" * 50

  puts "Виконані оптимізації:".cyan.bold
  changes.each { |change| puts "#{change}" }

  puts "-" * 50
  puts "Новий вираз: #{optimized_tokens.map(&:value).join(' ').gray}".cyan.bold
else
  puts "Знайдені помилки:".cyan.bold
  errors.each do |error|
    pointer = " " * error.position + "^".red.bold
    puts "\n#{input}\n#{pointer}"
    puts "#{error.message.red.bold}"
  end

  puts "\nВираз містить помилки (#{errors.length})!".underline.bold
  exit
end
