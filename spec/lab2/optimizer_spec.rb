require 'spec_helper'
require_relative '../../lab1/tokenizer'
require_relative '../../lab2/optimizer'

RSpec.describe 'Optimizer' do
  let(:optimizer) { Optimizer.new([]) }

  describe '#apply_unary_minus' do
    it 'converts unary minus at start of expression' do
      tokens = [
        Token.new(:OPERATOR, '-', 0),
        Token.new(:NUMBER, '5', 1) 
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:apply_unary_minus, tokens)
      expect(result.map(&:value)).to eq(['0', '-', '5'])
    end

    it 'converts unary minus after left parenthesis' do
      tokens = [
        Token.new(:LPAREN, '(', 0),
        Token.new(:OPERATOR, '-', 1),
        Token.new(:NUMBER, '3', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:apply_unary_minus, tokens)
      expect(result.map(&:value)).to eq(['(', '0', '-', '3'])
    end

    it 'does not convert binary minus' do
      tokens = [
        Token.new(:NUMBER, '5', 0),
        Token.new(:OPERATOR, '-', 1),
        Token.new(:NUMBER, '3', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:apply_unary_minus, tokens)
      expect(result.map(&:value)).to eq(['5', '-', '3'])
    end
  end

  describe '#remove_multiplication_division_by_one' do
    it 'removes multiplication by one from left' do
      tokens = [
        Token.new(:NUMBER, '1', 0),
        Token.new(:OPERATOR, '*', 1), 
        Token.new(:NUMBER, '5', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_division_by_one, tokens)
      expect(result.map(&:value)).to eq(['5'])
    end

    it 'removes multiplication by one from right' do
      tokens = [
        Token.new(:NUMBER, '5', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '1', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_division_by_one, tokens)
      expect(result.map(&:value)).to eq(['5'])
    end

    it 'removes division by one' do
      tokens = [
        Token.new(:NUMBER, '8', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:NUMBER, '1', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_division_by_one, tokens)
      expect(result.map(&:value)).to eq(['8'])
    end

    it 'handles decimal one values' do
      tokens = [
        Token.new(:NUMBER, '1.0', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '6', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_division_by_one, tokens)
      expect(result.map(&:value)).to eq(['6'])
    end

    it 'handles number and variable multiplication with one' do
      tokens = [
        Token.new(:NUMBER, '1', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:IDENTIFIER, 'x', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_division_by_one, tokens)
      expect(result.map(&:value)).to eq(['x'])
    end

    it 'handles variable and one multiplication' do
      tokens = [
        Token.new(:IDENTIFIER, 'y', 0), 
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '1', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_division_by_one, tokens)
      expect(result.map(&:value)).to eq(['y'])
    end

    it 'handles variable division by one' do
      tokens = [
        Token.new(:IDENTIFIER, 'z', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:NUMBER, '1.0', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens) 
      result = optimizer.send(:remove_multiplication_division_by_one, tokens)
      expect(result.map(&:value)).to eq(['z'])
    end

    it 'preserves division of two variables' do
      tokens = [
        Token.new(:IDENTIFIER, 'x', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:IDENTIFIER, 'y', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_division_by_one, tokens) 
      expect(result.map(&:value)).to eq(['x', '/', 'y'])
    end

    it 'preserves variable division' do
      tokens = [
        Token.new(:NUMBER, '6', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:IDENTIFIER, 'x', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_division_by_one, tokens)
      expect(result.map(&:value)).to eq(['6', '/', 'x'])
    end
  end

  describe '#remove_multiplication_by_zero' do
    it 'replaces multiplication by zero from left' do
      tokens = [
        Token.new(:NUMBER, '0', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '5', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_by_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'replaces multiplication by zero from right' do
      tokens = [
        Token.new(:NUMBER, '5', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '0', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_by_zero, tokens)
      expect(result.map(&:value)).to eq(['0']) 
    end

    it 'handles decimal zero values' do
      tokens = [
        Token.new(:NUMBER, '0.0', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '6', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_by_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'handles variable multiplied by zero from right' do
      tokens = [
        Token.new(:IDENTIFIER, 'x', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '0', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_by_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'handles decimal zero multiplication with variable from right' do
      tokens = [
        Token.new(:IDENTIFIER, 'y', 0), 
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '0.0', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_by_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'handles decimal zero multiplication with variable from left' do
      tokens = [
        Token.new(:NUMBER, '0.0', 0),
        Token.new(:OPERATOR, '*', 1), 
        Token.new(:IDENTIFIER, 'z', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_by_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'preserves non-zero multiplication' do
      tokens = [
        Token.new(:NUMBER, '5', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '3', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_multiplication_by_zero, tokens)
      expect(result.map(&:value)).to eq(['5', '*', '3'])
    end
  end

  describe '#remove_addition_subtraction_of_zero' do
    it 'removes addition of zero from left' do
      tokens = [
        Token.new(:NUMBER, '0', 0),
        Token.new(:OPERATOR, '+', 1),
        Token.new(:NUMBER, '5', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_addition_subtraction_of_zero, tokens)
      expect(result.map(&:value)).to eq(['5'])
    end

    it 'removes addition of zero from right' do
      tokens = [
        Token.new(:NUMBER, '5', 0),
        Token.new(:OPERATOR, '+', 1),
        Token.new(:NUMBER, '0', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_addition_subtraction_of_zero, tokens)
      expect(result.map(&:value)).to eq(['5'])
    end

    it 'removes subtraction of zero from right' do
      tokens = [
        Token.new(:NUMBER, '8', 0),
        Token.new(:OPERATOR, '-', 1),
        Token.new(:NUMBER, '0', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_addition_subtraction_of_zero, tokens)
      expect(result.map(&:value)).to eq(['8'])
    end

    it 'handles decimal zero values' do
      tokens = [
        Token.new(:NUMBER, '6', 0),
        Token.new(:OPERATOR, '+', 1),
        Token.new(:NUMBER, '0.0', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_addition_subtraction_of_zero, tokens)
      expect(result.map(&:value)).to eq(['6'])
    end

    it 'handles addition of zero with variables' do
      tokens = [
        Token.new(:NUMBER, '0', 0),
        Token.new(:OPERATOR, '+', 1),
        Token.new(:IDENTIFIER, 'x', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_addition_subtraction_of_zero, tokens)
      expect(result.map(&:value)).to eq(['x'])
    end

    it 'preserves subtraction from zero' do
      tokens = [
        Token.new(:NUMBER, '0', 0),
        Token.new(:OPERATOR, '-', 1),
        Token.new(:NUMBER, '5', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_addition_subtraction_of_zero, tokens)
      expect(result.map(&:value)).to eq(['0', '-', '5'])
    end

    it 'preserves non-zero additions' do
      tokens = [
        Token.new(:NUMBER, '3', 0),
        Token.new(:OPERATOR, '+', 1),
        Token.new(:NUMBER, '5', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_addition_subtraction_of_zero, tokens)
      expect(result.map(&:value)).to eq(['3', '+', '5'])
    end
  end

  describe '#remove_division_of_zero' do
    it 'removes division of zero by variable' do
      tokens = [
        Token.new(:NUMBER, '0', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:IDENTIFIER, 'x', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_division_of_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'handles decimal zero division by variable' do
      tokens = [
        Token.new(:NUMBER, '0.0', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:IDENTIFIER, 'y', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_division_of_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'preserves division of non-zero by variable' do 
      tokens = [
        Token.new(:NUMBER, '5', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:IDENTIFIER, 'z', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_division_of_zero, tokens)
      expect(result.map(&:value)).to eq(['5', '/', 'z'])
    end

    it 'preserves variable division by variable' do
      tokens = [
        Token.new(:IDENTIFIER, 'x', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:IDENTIFIER, 'y', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_division_of_zero, tokens)
      expect(result.map(&:value)).to eq(['x', '/', 'y'])
    end

    it 'removes division of zero by number' do
      tokens = [
        Token.new(:NUMBER, '0', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:NUMBER, '5', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_division_of_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'handles decimal zero division by number' do
      tokens = [
        Token.new(:NUMBER, '0.0', 0), 
        Token.new(:OPERATOR, '/', 1),
        Token.new(:NUMBER, '3', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_division_of_zero, tokens)
      expect(result.map(&:value)).to eq(['0'])
    end

    it 'preserves division of non-zero numbers' do
      tokens = [
        Token.new(:NUMBER, '6', 0),
        Token.new(:OPERATOR, '/', 1), 
        Token.new(:NUMBER, '2', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:remove_division_of_zero, tokens)
      expect(result.map(&:value)).to eq(['6', '/', '2'])
    end
  end

  describe '#combine_constants' do
    it 'combines addition of two numbers' do
      tokens = [
        Token.new(:NUMBER, '2', 0),
        Token.new(:OPERATOR, '+', 1),
        Token.new(:NUMBER, '3', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['5'])
    end

    it 'combines subtraction of two numbers' do
      tokens = [
        Token.new(:NUMBER, '8', 0),
        Token.new(:OPERATOR, '-', 1),
        Token.new(:NUMBER, '3', 2)  
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['5'])
    end

    it 'combines negative numbers properly' do
      tokens = [
      Token.new(:NUMBER, '-5', 0),
      Token.new(:OPERATOR, '+', 1),
      Token.new(:NUMBER, '-3', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['-8'])
    end

    it 'handles subtraction resulting in negative number' do
      tokens = [
      Token.new(:NUMBER, '2', 0),
      Token.new(:OPERATOR, '-', 1),
      Token.new(:NUMBER, '5', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens) 
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['-3'])
    end

    it 'combines multiplication of two numbers' do
      tokens = [
        Token.new(:NUMBER, '4', 0),
        Token.new(:OPERATOR, '*', 1),
        Token.new(:NUMBER, '3', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['12'])
    end

    it 'combines division of two numbers' do
      tokens = [
        Token.new(:NUMBER, '15', 0),
        Token.new(:OPERATOR, '/', 1),
        Token.new(:NUMBER, '3', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['5'])
    end

    it 'preserves operations with variables' do
      tokens = [
        Token.new(:NUMBER, '2', 0),
        Token.new(:OPERATOR, '+', 1),
        Token.new(:IDENTIFIER, 'x', 2)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['2', '+', 'x'])
    end

    it 'handles multiple decimal constant operations' do
      tokens = [
      Token.new(:NUMBER, '1.5', 0),
      Token.new(:OPERATOR, '+', 1), 
      Token.new(:NUMBER, '2.5', 2),
      Token.new(:OPERATOR, '-', 3),
      Token.new(:NUMBER, '1.0', 4)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['3'])
    end

    it 'preserves variables between constant operations' do
      tokens = [
        Token.new(:NUMBER, '2', 0),
        Token.new(:OPERATOR, '+', 1),
        Token.new(:NUMBER, '3', 2), 
        Token.new(:OPERATOR, '*', 3),
        Token.new(:IDENTIFIER, 'x', 4),
        Token.new(:OPERATOR, '+', 5),
        Token.new(:NUMBER, '4', 6),
        Token.new(:OPERATOR, '-', 7),
        Token.new(:NUMBER, '1', 8)
      ]
      optimizer.instance_variable_set(:@tokens, tokens)
      result = optimizer.send(:combine_constants, tokens)
      expect(result.map(&:value)).to eq(['5', '*', 'x', '+', '3'])
    end
  end
end