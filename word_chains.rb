require './tyler_treenodes.rb'

class Chainer
  attr_reader :start_word, :end_word, :dict
  def initialize(start_word, end_word)
    @start_word = start_word
    @end_word = end_word
    @dict = build_dictionary
    chain
  end

  def build_dictionary
    words = File.readlines("dictionary.txt").map{|line| line.chomp!}
    words.map!{|word| word.gsub(/[\'\%]/, "")}
    words.select!{|word| word.length == @start_word.length}
    words = Set.new(words) - [@start_word]
  end

  def adj_words(word)
    adjacent_words = Set.new

    word.length.times do |index|
      ("a".."z").each do |letter|
        new_word = word.dup
        new_word[index] = letter

        adjacent_words << new_word if @dict.include?(new_word)
      end
    end
    adjacent_words
  end

  def chain
    options = {
      :start_word => @start_word,
      :goal_value => @end_word,
      :values => @dict
    }
    @words = Tree.new(options){|word| adj_words(word)}
    @words.build_tree
    p @words.root_node.dfs(@end_word).reconstruct_path.reverse
  end
end


times = []
100.times do
  start_time = Time.now
  test = Chainer.new("duck", "ruby")
  times <<  Time.now - start_time
end
p times.inject(:+)/100
