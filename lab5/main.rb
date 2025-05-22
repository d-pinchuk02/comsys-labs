#!/usr/bin/env ruby

require "../lab1/formatter"
require "../lab1/tokenizer"
require "../lab1/validator"
require "../lab2/optimizer"
require "../lab2/tree"
require "./scheduler"

input = File.read("input.txt")

tokenizer = Tokenizer.new(input)
tokens = tokenizer.tokenize
tokenizer_errors = tokenizer.errors

validator = Validator.new(tokens)
validator_errors = validator.validate

errors = tokenizer_errors + validator_errors

puts "ПЗКС - Лабораторна робота №5".cyan.bold
puts "-" * 50
puts "Аналіз виразу: #{input.gray}".cyan.bold
puts "-" * 50

if errors.empty?
  puts "Вираз правильний.".green.bold

  optimizer = Optimizer.new(tokens)
  optimized_tokens, changes = optimizer.optimize

  if !changes.empty?
    puts "-" * 50
    puts "Виконані оптимізації:".cyan.bold
    changes.each { |change| puts "#{change}" }
  end

  tree_builder = TreeBuilder.new()
  postfix = tree_builder.infix_to_postfix(optimized_tokens)
  tree = tree_builder.postfix_to_tree(postfix)
  balanced_tree = tree_builder.balance_tree(tree)
  puts "-" * 50
  puts "Паралельне дерево виразу:".cyan.bold
  puts balanced_tree.to_s

  puts "-" * 50
  scheduler = Scheduler.new
  scheduler.schedule_expression(balanced_tree)
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
