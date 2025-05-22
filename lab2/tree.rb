TreeNode = Struct.new(:value, :left, :right) do
  def to_s
    def build_tree_string(node = self, prefix = "", is_left = true)
      return "" if node.nil?

      result = ""
      result += build_tree_string(node.right, "#{prefix}#{is_left ? "│   " : "    "}", false)
      result += "#{prefix}#{is_left ? "└── " : "┌── "}#{node.value}\n"
      result += build_tree_string(node.left, "#{prefix}#{is_left ? "    " : "│   "}", true)
      result
    end

    build_tree_string
  end
end

class TreeBuilder
  PRECEDENCE = { '(' => 0, ')' => 0, '+' => 1, '-' => 1, '*' => 2, '/' => 2 }.freeze

  def initialize
  end

  def infix_to_postfix(tokens)
    output = []
    stack = []
    
    tokens.each do |token|
      case token.type
      when :NUMBER, :IDENTIFIER
        output << token
      when :OPERATOR
        while !stack.empty? && PRECEDENCE[stack.last.value] >= PRECEDENCE[token.value]
          output << stack.pop
        end
        stack.push(token)
      when :LPAREN
        stack.push(token)
      when :RPAREN
        while !stack.empty? && stack.last.type != :LPAREN
          output << stack.pop
        end
        stack.pop # Remove the left parenthesis from the stack
      end
    end
    while !stack.empty?
      output << stack.pop
    end
    output
  end

  def postfix_to_tree(tokens)
    stack = []
    tokens.each do |token|
      case token.type
      when :NUMBER, :IDENTIFIER
        stack.push(TreeNode.new(token.value, nil, nil))
      when :OPERATOR
        right = stack.pop
        left = stack.pop
        stack.push(TreeNode.new(token.value, left, right))
      end
    end
    stack.pop
  end

  def height(node)
    return 0 if node.nil?
    1 + [height(node.left), height(node.right)].max
  end

  def balance_factor(node)
    return 0 if node.nil?
    height(node.left) - height(node.right)
  end

  def right_rotate(y)
    return y if y.nil? || y.left.nil?
    x = y.left
    t2 = x.right
    x.right = y
    y.left = t2
    x
  end

  def left_rotate(x)
    return x if x.nil? || x.right.nil?
    y = x.right
    t2 = y.left
    y.left = x
    x.right = t2
    y
  end

  def balance_tree(node)
    return nil if node.nil?

    loop do
      node.left = balance_tree(node.left)
      node.right = balance_tree(node.right)

      bf = balance_factor(node)
      balanced = true

      # Left heavy
      if bf > 1
        if balance_factor(node.left) < 0
          node.left = left_rotate(node.left)
        end
        node = right_rotate(node)
        balanced = false
      end

      # Right heavy
      if bf < -1
        if balance_factor(node.right) > 0
          node.right = right_rotate(node.right)
        end
        node = left_rotate(node)
        balanced = false
      end

      break if balanced
    end

    node
  end
end
