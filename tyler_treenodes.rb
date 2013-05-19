require 'debugger'
require 'set'
class Tree
  attr_reader :root_node, :goal_value
  def initialize(opt = {}, &prc)
    @root_node = TreeNode.new(opt[:start_word])
    @goal_value = opt[:goal_value]
    @values_remain = Set.new(opt[:values])
    @used_values = Set.new([@root_node.value])
    @active_nodes = [@root_node]
    @rule = prc
  end

  def build_tree
    until @active_nodes.empty?
      return if @used_values.include?(@goal_value)
      active_node = @active_nodes.shift
      build_children(active_node, get_child_values(active_node))
    end
  end

  def build_children(node, children_values)
    children_values.each{|value| node.child = TreeNode.new(value)}
    @active_nodes += (node.children)
  end

  def get_child_values(node)
    child_values = @values_remain.dup
    adjacent_steps = @rule.call(node.value)
    child_values.keep_if do |value|
      adjacent_steps.include?(value) &&
        !@used_values.include?(value)
    end
    update_sets(child_values)
    child_values
  end

  def update_sets(child_values)
    @values_remain.subtract(child_values)
    @used_values.merge(child_values)
  end
end


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
    p "Parent has value #{parent.value}" unless parent.nil?
    p "This node has value #{self.value}"
    p "Children's values: #{children_values}"
    puts
  end
end



# test = Tree.new(2, 100, (0..1000).to_a){|node, value| value%node.value == 0 }
# test.build_tree
# p test.root_node.dfs(70).reconstruct_path
