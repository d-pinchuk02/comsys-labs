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

  def balance_tree(node)
    return nil if node.nil?

    # Separate operators and operands
    operators, operands = inorder_traversal(node)
    # Rebuild balanced tree
    build_balanced_tree(operators, operands, 0, operands.length)
  end

  private

  def inorder_traversal(node, operators = [], operands = [])
    return [operators, operands] if node.nil?
    
    inorder_traversal(node.left, operators, operands)
    if node.left.nil? && node.right.nil?
      operands << node
    else
      operators << node
    end
    inorder_traversal(node.right, operators, operands)
    [operators, operands]
  end

  def build_balanced_tree(operators, operands, start, finish)
    return operands.shift if start >= finish
    
    mid = (start + finish) / 2
    node = TreeNode.new(operators.shift.value, nil, nil)
    
    node.left = build_balanced_tree(operators, operands, start, mid - 1)
    node.right = build_balanced_tree(operators, operands, mid + 1, finish)
    
    node
  end
end