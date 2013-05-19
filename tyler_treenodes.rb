class TreeNode
  attr_accessor :parent, :children, :value

  def initialize(value, parent = nil)
    @parent = parent
    @value = value
    @children = []
  end

  def child=(child)
    child.parent = self
    self.children << child
  end

  def each_child(&prc)
    @children.each{|child| prc.call(child)}
  end

  def map_children(&prc)
    @children.map{|child| prc.call(child)}
  end

  def children_values
    values = []
    @children.each{|child| values << child.value}
    values
  end

  def dfs(target = nil, &prc)
    prc = Proc.new{|node| node.value == target} unless prc
    return self if prc.call(self)

    child_dfs = nil
    self.each_child do |child|
      return child if prc.call(child)
      child_dfs = child.dfs{|child| prc.call(child)}
      break unless child_dfs.nil?
    end

    child_dfs
  end

  def bfs(target = nil, &prc)
    prc = Proc.new{|node| node.value == target} unless prc
    search = [self]
    until search.empty?
      node = search.shift
      return node if prc.call(node)

      search += node.children
    end
    nil
  end

  def quantity_children
    self.children.length
  end

  def reconstruct_path
    return [self.value] if self.parent.nil?
    [self.value] + self.parent.reconstruct_path
  end

  def youngest_child
    self.dfs{|node| node.children.empty?}
  end

  def with_children(num_children)
    self.bfs{|node| node.children.length == num_children}
  end

  def info
    puts
    p "Parent has value #{parent.value}"
    p "This node has value #{self.value}"
    p "Children's values: #{children_values}"
    puts
  end
end