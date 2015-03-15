# encoding: UTF-8
require "randexp"

module Feedback
  def feedback(label)
    case label
      when "incorrect"
        puts "\n\tERROR at word \##{spelling_checker + 1}.\tYou have #{@n_of_attempts} attempts left.\n\n"
      when "correct_ans"
        puts "\n\t#{@all_variations[0]}"
      when "header"
        puts "\n\n-> TEST #{@questions.index(@current_q) + 1} (of #{@questions.size})\n\n"
      when "score"
        puts "\n\tYour score is #{@score} points."
      when "efficiency"
        puts "\n\n-> EFFICIENCY: #{(@score * 100) / (@questions.size * 9)} %\n\n\n\n"
      when "welcome"
        puts "\n\n#{("\n"*0)}-> WELCOME TO QUIZMASTER! What is your name?\n"
      when "current_question"
        puts "#{@current_q}"
      when "padding"
        puts "\n"*50
      when "splash"
        puts '
           ____        _       __  ___           __
          / __ \__  __(_)___  /  |/  /___  _____/ / ___  _____
         / / / / / / / /_  / / /|_/ / __ `/ ___/ __/ _ \/ ___/
        / /_/ / /_/ / / / /_/ /  / / /_/ (__  ) /_/  __/ /
        \___\_\__,_/_/ /___/_/  /_/\__,_/____/\__/\___/_/
         by gabriel cabrejas'

      when "success"
        #puts "\n"*2
        puts '
         ___ _   _  ___ ___ ___ ___ ___ _
        / __| | | |/ __/ __| __/ __/ __| |
        \__ \ |_| | (_| (__| _|\__ \__ \_|
        |___/\___/ \___\___|___|___/___(_)'

      when"failure"
        #puts "\n"
        puts '
         █████▒▄▄▄       ██▓ ██▓     █    ██  ██▀███  ▓█████
       ▓██   ▒▒████▄    ▓██▒▓██▒     ██  ▓██▒▓██ ▒ ██▒▓█   ▀
       ▒████ ░▒██  ▀█▄  ▒██▒▒██░    ▓██  ▒██░▓██ ░▄█ ▒▒███
       ░▓█▒  ░░██▄▄▄▄██ ░██░▒██░    ▓▓█  ░██░▒██▀▀█▄  ▒▓█  ▄
       ░▒█░    ▓█   ▓██▒░██░░██████▒▒▒█████▓ ░██▓ ▒██▒░▒████▒
        ▒ ░    ▒▒   ▓▒█░░▓  ░ ▒░▓  ░░▒▓▒ ▒ ▒ ░ ▒▓ ░▒▓░░░ ▒░ ░
        ░       ▒   ▒▒ ░ ▒ ░░ ░ ▒  ░░░▒░ ░ ░   ░▒ ░ ▒░ ░ ░  ░
        ░ ░     ░   ▒    ▒ ░  ░ ░    ░░░ ░ ░   ░░   ░    ░
                    ░  ░ ░      ░  ░   ░        ░        ░  ░'
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
  attr_reader :n_of_attempts, :points
  include Feedback

  def initialize(question, answer)
    @question = question
    @pattern = eval(answer)
    @n_of_attempts = 3
    @points = 0
    @all_variations = []
  end

  def attempt
    @attempt = $stdin.gets.chomp
  end

  def to_output(player)
    File.open("mistakes/MISTAKES_#{player}.txt", "a") do |i|
      i.puts @question
      i.puts "#{@attempt}\n\n"
    end
  end

  def checker(player)
    loop_through_gen
    if spelling_checker == 1000
      feedback("success")
      @points += @n_of_attempts ** 2
      @n_of_attempts = 0
    else
      spelling_checker
      to_output(player)
      @n_of_attempts -= 1
      feedback("incorrect")
      feedback("failure") if @n_of_attempts == 0
      feedback("correct_ans") if @n_of_attempts == 0
    end
  end

  def gen_fix_save_variation
    generated = @pattern.gen
    question_mark_count = @question.scan(/\?/).count
    if question_mark_count > 0
      valid = generated.gsub(/\\/,"?") if generated.scan(/\\/).count == question_mark_count
      @all_variations << valid unless @all_variations.include?(valid) || valid.nil?
    else
      @all_variations << generated unless @all_variations.include?(generated)
    end
  end

  def loop_through_gen
    (1..500).each {gen_fix_save_variation}
    #print "Correct variations: ", @all_variations
  end

  def spelling_checker
    @correctness_array = []
    split_attempt = @attempt.split
    #print "\nSplit attempt: ", split_attempt
    @all_variations.each do |variant|
      correctness_index = 0
      variation = variant.split
      max_index = variation.size
      #print "\nVariation: ", variation
      variation.each do |word|
        if word == split_attempt[variation.index(word)]
          correctness_index += 1
        else
          break
        end
      end
      if correctness_index < max_index
        @correctness_array << correctness_index
      else
        @correctness_array << 1000
      end
    end
    #print "\nCorrectness array: ", @correctness_array
    #print "\nCorrectness index: ", @correctness_array.max
    @correctness_array.max
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
    feedback("padding")
    feedback("splash")
    feedback("welcome")
    @user = $stdin.gets.chomp
  end

  def run_single_test(q)
    @current_q = q
    feedback("header")
    single = Test.new(@current_q, @answers[@questions.index(@current_q)])
    while single.n_of_attempts > 0
      feedback("current_question")
      single.attempt
      single.checker(@user)
      @score += single.points
    end
    feedback("score")
  end

  def run_all_tests
    player_name
    @questions.each {|q| run_single_test(q)}
    feedback("efficiency")
  end
end

Game.new.run_all_tests