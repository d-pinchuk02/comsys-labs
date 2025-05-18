class Optimizer
  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
    @changes = []
  end

  def optimize
    @tokens = apply_unary_minus(@tokens)
    @tokens = remove_multiplication_division_by_one(@tokens)
    @tokens = remove_multiplication_by_zero(@tokens)
    @tokens = remove_addition_subtraction_of_zero(@tokens)
    @tokens = remove_division_of_zero(@tokens)
    @tokens = combine_constants(@tokens)
    [@tokens, @changes]
  end

  private

  def apply_unary_minus(tokens)
    new_tokens = []
    i = 0
    while i < tokens.length
      token = tokens[i]

      if (token.type == :OPERATOR && token.value == '-') &&
         (i == 0 || tokens[i-1].type == :LPAREN)
        new_tokens << Token.new(:NUMBER, '0', token.position)
        @changes << "Унарний мінус: -#{tokens[i+1].value} = 0-#{tokens[i+1].value}"
      end
      new_tokens << token

      i += 1
    end
    new_tokens
  end

  def remove_multiplication_division_by_one(tokens)
    new_tokens = []
    i = 0
    while i < tokens.length
      token = tokens[i]

      if i + 2 < tokens.length &&
         token.type == :NUMBER && (token.value == '1' || token.value == '1.0') &&
         tokens[i+1].type == :OPERATOR && (tokens[i+1].value == '*') &&
         (tokens[i+2].type == :NUMBER || tokens[i+2].type == :IDENTIFIER)
        @changes << "Множення/ділення на 1: 1#{tokens[i+1].value}#{tokens[i+2].value} = #{tokens[i+2].value}"
        new_tokens << tokens[i+2]
        i += 3
      elsif i > 0 && i + 1 < tokens.length &&
            token.type == :OPERATOR && (token.value == '*' || token.value == '/') &&
            tokens[i+1].type == :NUMBER && (tokens[i+1].value == '1' || tokens[i+1].value == '1.0')
        @changes << "Множення/ділення на 1: #{tokens[i-1].value}#{token.value}1 = #{tokens[i-1].value}"
        i += 2
      else
        new_tokens << token
        i += 1
      end
    end
    new_tokens
  end

  def remove_multiplication_by_zero(tokens)
    new_tokens = []
    i = 0
    while i < tokens.length
      token = tokens[i]

      if i + 2 < tokens.length &&
         token.type == :NUMBER && (token.value == '0' || token.value == '0.0') &&
         tokens[i+1].type == :OPERATOR && tokens[i+1].value == '*' &&
         (tokens[i+2].type == :NUMBER || tokens[i+2].type == :IDENTIFIER)
        @changes << "Множення на 0: 0*#{tokens[i+2].value} = 0"
        new_tokens << Token.new(:NUMBER, '0', token.position)
        i += 3
      elsif i > 0 && i + 1 < tokens.length &&
            token.type == :OPERATOR && token.value == '*' &&
            tokens[i+1].type == :NUMBER && (tokens[i+1].value == '0' || tokens[i+1].value == '0.0')
        @changes << "Множення на 0: #{tokens[i-1].value}*0 = 0"
        new_tokens.pop
        new_tokens << Token.new(:NUMBER, '0', token.position)
        i += 2
      else
        new_tokens << token
        i += 1
      end
    end
    new_tokens
  end

  def remove_addition_subtraction_of_zero(tokens)
    new_tokens = []
    i = 0
    while i < tokens.length
      token = tokens[i]

      if i + 2 < tokens.length &&
         token.type == :NUMBER && (token.value == '0' || token.value == '0.0') &&
         tokens[i+1].type == :OPERATOR && (tokens[i+1].value == '+') &&
         (tokens[i+2].type == :NUMBER || tokens[i+2].type == :IDENTIFIER)
        @changes << "Додавання/віднімання 0: 0#{tokens[i+1].value}#{tokens[i+2].value} = #{tokens[i+2].value}"
        new_tokens << tokens[i+2]
        i += 3
      elsif i > 0 && i + 1 < tokens.length &&
            token.type == :OPERATOR && (token.value == '+' || token.value == '-') &&
            tokens[i+1].type == :NUMBER && (tokens[i+1].value == '0' || tokens[i+1].value == '0.0')
        @changes << "Додавання/віднімання 0: #{tokens[i-1].value}#{token.value}0 = #{tokens[i-1].value}"
        i += 2
      else
        new_tokens << token
        i += 1
      end
    end
    new_tokens
  end

  def remove_division_of_zero(tokens)
    new_tokens = []
    i = 0
    while i < tokens.length
      token = tokens[i]

      if i + 2 < tokens.length &&
         token.type == :NUMBER && (token.value == '0' || token.value == '0.0') &&
         tokens[i+1].type == :OPERATOR && tokens[i+1].value == '/' &&
         (tokens[i+2].type == :NUMBER || tokens[i+2].type == :IDENTIFIER)
        @changes << "Ділення 0: 0/#{tokens[i+2].value} = 0"
        new_tokens << Token.new(:NUMBER, '0', token.position)
        i += 3
      else
        new_tokens << token
        i += 1
      end
    end
    new_tokens
  end

  def combine_constants(tokens)
    new_tokens = []
    i = 0
    while i < tokens.length
      token = tokens[i]

      if token.type == :NUMBER
        sequence = [token]
        j = i + 1
        while j + 1 < tokens.length && 
              tokens[j].type == :OPERATOR &&
              tokens[j+1].type == :NUMBER
          sequence << tokens[j] << tokens[j+1]
          j += 2
        end

        if sequence.length > 1
          result = sequence[0].value.to_f
          operations = []
          (1...sequence.length).step(2) do |k|
            operator = sequence[k].value
            number = sequence[k+1].value.to_f
            case operator
            when '+' then result += number
            when '-' then result -= number
            when '*' then result *= number
            when '/' then result = result.fdiv(number)
            end
            operations << "#{sequence[k].value}#{sequence[k+1].value}"
          end
          
          @changes << "Обчислення констант: #{sequence[0].value}#{operations.join} = #{result}"
          new_tokens << Token.new(:NUMBER, ('%.5g' % result), token.position)
          i = j
        else
          new_tokens << token
          i += 1
        end
      else
        new_tokens << token
        i += 1
      end
    end

    new_tokens.length != tokens.length ? combine_constants(new_tokens) : new_tokens
  end
end