Token = Struct.new(:type, :value, :position) do
  def to_s = "[#{self.type}, #{self.value}, pos: #{self.position}]"
end

class LexicalError < StandardError
  attr_reader :position

  def initialize(message, position)
    super("#{message} на позиції #{position.to_s.underline}")
    @position = position
  end
end

class Tokenizer
  attr_reader :errors

  def initialize(input)
    @input = input
    @position = 0
    @tokens = []
    @errors = []
  end

  def tokenize
    while @position < @input.length
      char = current_char

      case char
      when /\s/
        handle_whitespace
      when '(', ')'
        add_token(char == '(' ? :LPAREN : :RPAREN, char)
        advance
      when '+', '-', '*', '/', '^'
        add_token(:OPERATOR, char)
        advance
      when /[0-9]/, '.'
        tokenize_number
      when /[a-zA-Z_]/
        tokenize_identifier
      when ','
        add_token(:COMMA, char)
        advance
      else
        add_error("Неочікуваний символ '#{char}'", @position)
        advance
      end
    end

    @tokens
  end

  private

  def current_char
    @input[@position]
  end

  def peek
    return nil if @position + 1 >= @input.length
    @input[@position + 1]
  end

  def advance
    @position += 1
  end

  def add_token(type, value, position = @position)
    @tokens << Token.new(type, value, position)
  end

  def add_error(message, position)
    @errors << LexicalError.new(message, position)
  end

  def handle_whitespace
    while @position < @input.length && current_char =~ /\s/
      advance
    end
  end

  def tokenize_number
    integer_part = ''
    decimal_part = ''
    has_decimal_point = false
    origin_position = @position

    while @position < @input.length
      char = current_char

      if char == '.'
        if has_decimal_point
          add_error("Зайва десяткова крапка", @position)
          advance
          next
        end
        has_decimal_point = true
        advance

        if current_char == '.'
          add_error("Повторна десяткова крапка", @position)
          advance
          next
        end
      elsif char =~ /[0-9]/
        if has_decimal_point
          decimal_part += char
        else
          integer_part += char
        end
        advance
      else
        break
      end
    end

    if has_decimal_point
      while @position < @input.length && current_char =~ /[0-9]/
        decimal_part += current_char
        advance
      end
    end

    if integer_part.empty? && has_decimal_point
      number = "0.#{decimal_part}"
    elsif has_decimal_point && decimal_part.empty?
      number = "#{integer_part}.0"
    elsif has_decimal_point
      number = "#{integer_part}.#{decimal_part}"
    else
      number = integer_part
    end

    if integer_part.start_with?('0') && integer_part.length > 1
      add_error("Неочікуваний початок числа", @position)
    end

    add_token(:NUMBER, number, origin_position)
  end

  def tokenize_identifier
    identifier = ''
    origin_position = @position
    
    while @position < @input.length && current_char =~ /[a-zA-Z0-9_]/
      identifier += current_char
      advance
    end

    if identifier =~ /^[a-zA-Z_][a-zA-Z0-9_]*/
      add_token(:IDENTIFIER, identifier, origin_position)
    else
      add_error("Некоректний ідентифікатор '#{identifier}'", @position)
    end
  end
end
