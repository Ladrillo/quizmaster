require 'randexp'

module Feedback
  def feedback(label)
    case label
      when 'correct'
        puts "\n\tCORRECT!! :)"
      when 'incorrect'
        puts "\n\tINCORRECT. :(\tYou have #{@n_of_attempts} attempts left.", "\n"
      when 'correct_ans'
        puts "\tOne possible answer was: \"#{@pattern.gen}\"" if @n_of_attempts == 0
      when 'header'
        puts "\n\n-> TEST #{@questions.index(@current_q) + 1} (of #{@questions.size})", "\n"
      when 'score'
        puts "\n\tYour score is #{@score} points."
      when 'efficiency'
        puts "\n\n-> EFFICIENCY: #{(@score * 100) / (@questions.size * 9)} %", "\n\n"
    end
  end
end

class MyArrays
  attr_accessor :questions_array, :answers_array

  def initialize
    @questions_array = rip_lines.select {|q| rip_lines.index(q) % 2 == 0}
    @answers_array = rip_lines.select {|a| rip_lines.index(a) % 2 != 0}
  end

  def rip_lines
    q_and_a = []
    File.read(ARGV.first).each_line {|line| q_and_a << line.chomp}
    q_and_a
  end
end

class SingleTest
  attr_accessor :n_of_attempts, :points
  include Feedback

  def initialize(answer)
    @n_of_attempts = 3
    @points = 0
    @pattern = eval(answer)
  end

  def attempt
    @attempt = $stdin.gets.chomp
  end

  def comparor
    (@attempt =~ @pattern) == 0 ? true : false
  end

  def checker
    if comparor
      feedback('correct')
      @points += @n_of_attempts ** 2
      @n_of_attempts = 0
    else
      @n_of_attempts -= 1
      feedback('incorrect')
      feedback('correct_ans')
    end
  end
end

class AllTests
  include Feedback

  def initialize
    @new_set = MyArrays.new
    @questions = @new_set.questions_array
    @answers = @new_set.answers_array
  end

  def run_tests
    @score = 0
    @questions.each do |q|
      @current_q = q
      feedback('header')
      single = SingleTest.new(@answers[@questions.index(@current_q)])
      while single.n_of_attempts > 0
        puts @current_q
        single.attempt
        single.checker
        @score += single.points
      end
      feedback('score')
    end
    feedback('efficiency')
  end
end

AllTests.new.run_tests