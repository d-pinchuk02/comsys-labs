INVALID_UNARY_OPERATORS = ['*', '/', '^']

class MySyntaxError < StandardError
  attr_reader :position

  def initialize(message, position)
    super("#{message} на позиції #{position.to_s.underline}")
    @position = position
  end
end

class Validator
  def initialize(tokens)
    @tokens = tokens
    @position = 0
    @errors = []
  end

  def validate
    return [] if @tokens.empty?
    validate_syntax
    @errors
  end

  private

  def current_token
    @tokens[@position]
  end

  def peek_token
    @tokens[@position + 1]
  end

  def advance
    @position += 1
  end

  def add_error(message, token)
    @errors << MySyntaxError.new(message, token.position)
  end

  def validate_syntax
    validate_first_token if current_token

    while @position < @tokens.length - 1
      current = current_token
      next_token = peek_token

      case current.type
      when :NUMBER
        validate_after_number(current, next_token)
      when :OPERATOR
        validate_operator_context(current, next_token)
      when :IDENTIFIER
        validate_after_identifier(current, next_token)
      when :LPAREN
        validate_after_left_paren(current, next_token)
      when :RPAREN
        validate_after_right_paren(current, next_token)
      when :COMMA
        validate_after_comma(current, next_token)
      end

      advance
    end

    validate_last_token if current_token
    validate_parentheses_balance
  end

  def validate_first_token
    token = current_token

    case token.type
    when :NUMBER
      if token.value.start_with?('0') && token.value != '0' && !token.value.start_with?('0.')
        add_error("Неочікуваний початок числа", token)
      end
    when :OPERATOR
      if INVALID_UNARY_OPERATORS.include?(token.value)
        add_error("Некоректний початок виразу '#{token.value}'", token)
      end
    when :RPAREN
      add_error("Некоректний початок виразу ')'", token)
    when :COMMA
      add_error("Некоректний початок виразу ','", token)
    end
  end

  def validate_operator_context(operator_token, next_token)
    return unless next_token

    case next_token.type
    when :OPERATOR
      add_error("Неочікуваний оператор '#{next_token.value}' після оператора '#{operator_token.value}'", next_token)
    when :RPAREN
      add_error("Неочікуваний оператор '#{operator_token.value}' перед закриваючою дужкою", next_token)
    when :COMMA
      add_error("Неочікувана кома після оператора '#{operator_token.value}'", next_token)
    when :NUMBER
      if operator_token.value == '/' && next_token.value.to_f == 0.0
        add_error("Ділення на нуль", operator_token)
      end
    end
  end

  def validate_after_number(number_token, next_token)
    return unless next_token

    case next_token.type
    when :NUMBER
      add_error("Пропущено оператор після числа '#{number_token.value}'", number_token)
    when :IDENTIFIER
      add_error("Некоректний ідентифікатор '#{number_token.value}#{next_token.value}'", number_token)
    when :LPAREN
      add_error("Неочікувана відкриваюча дужка після числа '#{number_token.value}'", number_token)
    end
  end

  def validate_after_identifier(identifier_token, next_token)
    return unless next_token

    case next_token.type
    when :NUMBER
      add_error("Неочікуване число '#{next_token.value}' після ідентифікатора '#{identifier_token.value}'", identifier_token)
    when :IDENTIFIER
      add_error("Неочікуваний ідентифікатор '#{next_token.value}' після ідентифікатора '#{identifier_token.value}'", identifier_token)
    end
  end

  def validate_after_left_paren(paren_token, next_token)
    return unless next_token

    case next_token.type
    when :COMMA
      add_error("Неочікувана кома після відкриваючої дужки", paren_token)
    when :OPERATOR
      if INVALID_UNARY_OPERATORS.include?(next_token.value)
        add_error("Некоректний початок виразу '#{next_token.value}'", next_token)
      end
    end
  end

  def validate_after_right_paren(paren_token, next_token)
    return unless next_token

    case next_token.type
    when :NUMBER
      add_error("Неочікуване число '#{next_token.value}' після закриваючої дужки", next_token)
    when :IDENTIFIER
      if peek_token&.type != :LPAREN
        add_error("Неочікуваний ідентифікатор '#{next_token.value}' після закриваючої дужки", next_token)
      end
    when :LPAREN
      add_error("Неочікувана відкриваюча дужка після закриваючої дужки", next_token)
    end
  end

  def validate_after_comma(comma_token, next_token)
    return unless next_token

    case next_token.type
    when :RPAREN
      add_error("Пропущено аргумент функції", next_token)
    when :COMMA
      add_error("Неочікувана кома після коми", next_token)
    when :OPERATOR
      add_error("Неочікуваний оператор '#{next_token.value}' після коми", next_token)
    end
  end

  def validate_last_token
    token = current_token

    case token.type
    when :OPERATOR
      if INVALID_UNARY_OPERATORS.include?(token.value)
        add_error("Неочікуваний оператор '#{token.value}' в кінці виразу", token)
      end
    when :COMMA
      add_error("Неочікувана кома в кінці виразу", token)
    when :LPAREN
      add_error("Відкриваюча дужка не має парної закриваючої", token)
    end
  end

  def validate_parentheses_balance
    stack = []
    @tokens.each do |token|
      case token.type
      when :LPAREN
        stack.push(token)
      when :RPAREN
        if stack.empty?
          add_error("Відкриваюча дужка не має парної закриваючої", token)
        else
          stack.pop
        end
      end
    end

    stack.each do |token|
      add_error("Незакрита відкриваюча дужка", token)
    end
  end
end
