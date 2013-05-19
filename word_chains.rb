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
    words = File.readlines("dictionary.txt").map{|line| line.downcase.chomp!}
    words.map{|word| word.gsub!("'", "")}
    words.map{|word| word.gsub!("%", "")}
    words.select!{|word| word.length == @start_word.length}
  end

  def adj_words?(word1, word2)
    letters1 = word1.split("")
    different_letters = 0
    letters1.each_with_index do |letter, index|
      different_letters += 1 if word2[index] != letter
    end
    different_letters == 1
  end

  def chain
    options = {
      :start_word => @start_word,
      :goal_value => @end_word,
      :values => @dict
    }
    @words = Tree.new(options){|word1, word2| adj_words?(word1, word2)}
    @words.build_tree
    p @words.root_node.dfs(@end_word).reconstruct_path.reverse
  end
end

start_time = Time.now
test = Chainer.new("duck", "ruby")
p Time.now - start_time
