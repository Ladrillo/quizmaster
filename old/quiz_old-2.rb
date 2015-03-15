require 'randexp'

module Feedback
  def feedback(label)
    case label
      when 'correct'
        puts "\n\tCORRECT!! :)"
      when 'incorrect'
        puts "\n\tINCORRECT. :(\tYou have #{@n_of_attempts} attempts left.\n\n"
      when 'correct_ans'
        puts "\tOne possible answer was: \"#{@pattern.gen}\""
      when 'header'
        puts "\n\n-> TEST #{@questions.index(@current_q) + 1} (of #{@questions.size})\n\n"
      when 'score'
        puts "\n\tYour score is #{@score} points."
      when 'efficiency'
        puts "\n\n-> EFFICIENCY: #{(@score * 100) / (@questions.size * 9)} %\n\n\n"
      when 'welcome'
        puts "#{("\n"*50)}-> WELCOME! What is your name?\n"
      when 'current_question'
        puts "#{@current_q}"
    end
  end
end

class MyArrays
  attr_reader :questions_array, :answers_array

  def initialize
    @questions_array = rip_lines.select {|q| rip_lines.index(q) % 2 == 0}
    @answers_array = rip_lines.select {|a| rip_lines.index(a) % 2 != 0}
  end

  def rip_lines
    IO.readlines(ARGV.first).each {|i| i.chomp}
  end
end

class Test
  attr_reader :n_of_attempts, :points, :question, :pattern, :attempt
  include Feedback

  def initialize(question, answer)
    @question = question
    @pattern = eval(answer)
    @n_of_attempts = 3
    @points = 0
  end

  def attempt
    @attempt = $stdin.gets.chomp
  end

  def compare
    (@attempt =~ @pattern) == 0 ? true : false
  end

  def to_output(player)
    File.open("mistakes/MISTAKES_#{player}.txt", 'a') do |i|
      i.puts @question
      i.puts "#{@attempt}\n\n"
    end
  end

  def checker(player)
    if compare
      feedback('correct')
      @points += @n_of_attempts ** 2
      @n_of_attempts = 0
    else
      to_output(player)
      @n_of_attempts -= 1
      feedback('incorrect')
      feedback('correct_ans') if @n_of_attempts == 0
    end
  end
end

class Game
  include Feedback

  def initialize
    @new_set = MyArrays.new
    @questions = @new_set.questions_array
    @answers = @new_set.answers_array
    @score = 0
  end

  def player_name
    feedback('welcome')
    @user = $stdin.gets.chomp
  end

  def run_single_test(q)
    @current_q = q
    feedback('header')
    single = Test.new(@current_q, @answers[@questions.index(@current_q)])
    while single.n_of_attempts > 0
      feedback('current_question')
      single.attempt
      single.checker(@user)
      @score += single.points
    end
    feedback('score')
  end

  def run_all_tests
    player_name
    @questions.each {|q| run_single_test(q)}
    feedback('efficiency')
  end
end

Game.new.run_all_tests