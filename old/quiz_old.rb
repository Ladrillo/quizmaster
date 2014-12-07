test_file = ARGV.first

require 'randexp'

text = []
File.read(test_file).each_line {|line| text << line.chomp}
#print text
#print "\n"

questions = []
text.each {|x| questions << x if text.index(x) % 2 == 0}
#print questions
#print "\n"

answers = []
text.each {|x| answers << x if text.index(x) % 2 != 0}
#print answers
#print "\n"

points = 0
number_of_questions = questions.size

questions.each do |question|
  number_of_attempts = 3
  puts "\n", "\n"
  puts "-> TEST #{questions.index(question) + 1} (of #{number_of_questions})"

  while number_of_attempts > 0
    puts question
    attempt = $stdin.gets.chomp
    pattern = eval(answers[questions.index(question)])

    if attempt =~ pattern
      points += number_of_attempts ** 2
      puts "\n\tCORRECT!! :) \n\tYour score is #{points} points."
      number_of_attempts = 0
    else
      number_of_attempts -= 1
      puts "\n\tINCORRECT. :(\n\tYou have #{number_of_attempts} attempts left.\n"
      puts "\tOne possible answer was: \"#{pattern.gen}\"\n" if number_of_attempts == 0
      puts "\n"
    end
  end
end

puts "\n\tSCORE: #{points}. EFFICIENCY: #{(points * 100) / (number_of_questions * 9)} %"
puts "\n", "\n"