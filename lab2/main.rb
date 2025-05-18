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

puts "ПЗКС - Лабораторна робота №2".blue.bold
puts "-" * 50
puts "Аналіз виразу: #{input.gray}".blue.bold
puts "-" * 50

puts "Токени:".blue.bold
puts "-" * 50
tokens.each do |token|
  puts "[#{token.position}] #{token.type.to_s.green.bold}: #{token.value}"
end

if errors.empty?
  puts "\nВираз правильний.".green.bold

  optimizer = Optimizer.new(tokens)
  optimized_tokens, changes = optimizer.optimize

  puts "Оптимізовані токени:".blue.bold
  puts "-" * 50
  optimized_tokens.each do |token|
    puts "[#{token.position}] #{token.type.to_s.green.bold}: #{token.value}"
  end

  puts "Виконані оптимізації:"
  changes.each { |change| puts "#{change}" }

  puts "-" * 50
  puts "Новий вираз: #{optimized_tokens.map(&:value).join(' ').gray}".blue.bold
  puts "-" * 50

else
  puts "-" * 50
  puts "Знайдені помилки:".blue.bold
  puts "-" * 50
  errors.each do |error|
    pointer = " " * error.position + "^".red.bold
    puts "\n#{input}\n#{pointer}"
    puts "#{error.message.red.bold}"
  end

  puts "\nВираз містить помилки (#{errors.length})!".underline.bold
  exit
end
