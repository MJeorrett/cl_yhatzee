# TODO
#
# - Figure out better alternative to 'add_list' method.  Need to have drawing separate
#   from initialisation to avoid having to calculate grid size (passed to display after
#   initializing grid) twice.  Possibly allow adding other information that is drawn after
#   initialization but before drawing.


class DisplayMatrix

  def initialize(width, height)
    @width = width
    @height = height
    reset()
  end

  # ditch the old matrix and create a blank new one with dimensions of @height & @width
  def reset()
    @d_mx = []
    @height.times { @d_mx.push(Array.new(@width, ' ')) }
  end
  
  # refresh the terminal window to show the current contents of the display matrix
  def show()
    system('clear')
    i = 0
    @d_mx.each { |line| puts ($mj_debug ? i.to_s : '') + line.join; i += 1 }
  end

  # add characters to a column of the matrix
  def draw_line_vert(col, row_start=0, l=@height, char='|', overwrite=true)
    for row in row_start..(row_start + l - 1)
      a_char = @d_mx[row][col] == '-' ? '+' : char
      @d_mx[row][col] = a_char if @d_mx[row][col] == nil || overwrite
    end
  end

  # add characters to a row of the matrix
  def draw_line_hor(row, col_start=0, l=@width, char='-', overwrite=true)
    for col in col_start..(col_start + l - 1)
      a_char = @d_mx[row][col] == '|' ? '+' : char
      @d_mx[row][col] = a_char if @d_mx[row][col] == nil || overwrite
    end
  end
  
  # write a string of characters to a row in the matrix
  def write_at(str, row, col_start)
    return if str == '' || str.nil?
    str_arr = str.split('')
    i = 0
    for col in col_start..(col_start + str.length - 1)
      @d_mx[row][col] = str_arr[i]
      i += 1
    end
  end
  
  # draw a box in the matrix; creates strings then uses 'write_at' method.
  def draw_box_at(row_start, col_start, width, height, char=nil, corner_char='+')
    corner_char = '+' if corner_char.nil?
    if char.nil?
      horz_char = '-'
      vert_char = '|'
    else
      horz_char = char
      vert_char = char
    end
    
    tb_row = corner_char + (horz_char * (width - 2)) + corner_char # top and bottom row
    mid_row = vert_char + (' ' * (width - 2)) + vert_char # middle row
    write_at(tb_row, row_start, col_start) # draw top row
    
    #draw middle rows
    for row in (row_start + 1)..(row_start + height - 2)
      write_at(mid_row, row, col_start)
    end
    
    write_at(tb_row, row_start + height - 1, col_start) # draw bottom row
  end
end

class Grid
  # Grid class 
  # 
  # Describes a grid decsribed by the column and row headings.
  # - the number and width of the headings determine the number and width of the columns
  # - the number of the row headings determine the number of rows
  #
  # METHODS
  # - 'draw_at' is used to add the grid to the display matrix
  # - 'add_list' is used to adda list of strings to the grid, change is immediately updated 
  #   to the display.
  
  attr_reader :width
  attr_reader :height
  
  def initialize(col_hs, row_hs)
    @col_hs = col_hs # columns headings string array
    @row_hs = row_hs # row headings string array
    
    @col_widths = []
    # calculate column 1 width from max legnth of first column heading and all row headings
    @col_widths[0] = ([@col_hs[0]] + @row_hs).map(&:length).max + 2
    
    #calculate other column widths from row_headings
    @col_hs[1..-1].reduce(1) { |i, h| @col_widths[i] = h.length + 2; i += 1}
    
    @width = @col_widths.reduce(:+) + @col_widths.length + 1
    @height = @row_hs.length * 2 + 1
  end
  
  def add_list(str_arr, row_start, col_i, display)
    # calculate the starting column in the display matrix
    col = @col_widths[0..(col_i - 1)].reduce(:+) + col_i + @col + 2
    # write each string to the display matrix
    str_arr.each_with_index do |str, i|
      display.write_at(str, @row + (row_start + i) * 2 + 1, col)
    end
  end
  
  def draw_at(row, col, display)
    @row = row # starting row
    @col = col # starting column
    
    #draw first vertical line
    display.draw_line_vert(col, row, @height)
    i = 0
    
    # draw other vertical lines & column headings
    @col_widths.reduce(0) do |cursor, w|
      display.write_at(@col_hs[i], row + 1, col + cursor + 2)
      cursor += w + 1
      display.draw_line_vert(cursor + col, row, @height)
      i += 1
      cursor
    end
  
    #draw first horizontal line
    display.draw_line_hor(row, col, @width)
    
    #draw other horizontal lines & row headings
    for i in 1..@row_hs.length do
      display.draw_line_hor(row + i * 2, col, @width)
      display.write_at(@row_hs[i - 1], row + i * 2 - 1, col + 2)
    end
  end
end

class Die

  NUM_PATS = [
  [],
  [
  "       ",
  "   0   ",
  "       "
  ], [
  " 0     ",
  "       ",
  "     0 "
  ], [
  " 0     ",
  "   0   ",
  "     0 "
  ], [
  " 0   0 ",
  "       ",
  " 0   0 "
  ], [
  " 0   0 ",
  "   0   ",
  " 0   0 "
  ], [
  " 0   0 ",
  " 0   0 ",
  " 0   0 "
  ]]
  
  attr_reader :number
  
  def initialize(row, col, display)
    @row = row # top row
    @col = col # left column
    @width = NUM_PATS[1].first.length + 2
    @height = NUM_PATS[1].length + 2
    @display = display
    @number = 1
    draw()
    @frozen = false
  end
  
  def roll
    if !@frozen
      @number = rand(1..6)
      draw()
    end
  end
  
  def draw
    # draw the surrounding box
    box_char = @frozen ? '*' : nil
    @display.draw_box_at(@row, @col, @width, @height, box_char, box_char)
    
    # draw the spots inside
    for i in 0..2
      patt = NUM_PATS[@number][i]
      patt = patt.gsub('0', 'X') if @frozen
      @display.write_at(patt, @row + i + 1, @col + 1)
    end
  end
  
  def toggle_frozen
    @frozen = !@frozen
    draw()
  end
  
  def set_frozen(frozen)
    @frozen = frozen
  end
end

class Game

  NO_GAMES = 3 # number of games
  ROLLS_PER_GAME = 3 # number of rolls per game

  COL_HEADINGS = [
    'UPPER SECTION',
    'UG1',
    'UG2',
    'UG3',
    '',
    'LOWER SECTION    ',
    'LG1',
    'LG2',
    'LG3'
  ]
  ROW_HEADINGS = [
    '',
    '(1s) ones',
    '(2s) twos',
    '(3s) threes',
    '(4s) fours',
    '(5s) fives',
    '(6s) sixes',
    'SCORE',
    'BONUS',
    'UPPER TOTAL',
    ' '
  ]
  COL5_HEADINGS = [
    '(3k) 3 of a kind',
    '(4k) 4 of a kind',
    '(fh) full house',
    '(ls) low straight',
    '(hs) high straight',
    '(yz) Yhatzee',
    '(ch) Chance',
    '',
    'LOWER TOTAL',
    'GRAND TOTAL'
  ]
  UPPER_SECTIONS = [
    '1s',
    '2s',
    '3s',
    '4s',
    '5s',
    '6s'
  ]
  LOWER_SECTIONS = [
    '3k',
    '4k',
    'fh',
    'ls',
    'hs',
    'yz',
    'ch'
  ]
  def initialize
    # initialize board grid
    @grid = Grid.new(COL_HEADINGS, ROW_HEADINGS)
    
    # initialize display
    @display = DisplayMatrix.new(@grid.width, @grid.height + 9)
    
    # draw board grid
    @grid.draw_at(1, 1, @display)
    @grid.add_list(COL5_HEADINGS, 1, 5, @display)
    
    # initialize dice
    @dice = []
    for i in 0..4
      @dice[i] = Die.new(25, 2 + 12 * i, @display)
    end
    
    # draw line under board and dice
    @display.draw_line_hor(31)
    @display.show
    
    # Introduction
    puts "This program assumes you know how to play yhatzee, if you don't then"
    puts "please find out how before starting."
    puts
    puts "Expand the console window so that you can see all of the game board."
    puts "- you can quit at any time but entering 'quit'"
    puts "- enter 'r' to roll the dice"
    puts "- to freeze dice before rolling enter their indexes e.g. '124' to freeze the"
    puts "  1st, 2nd and 4th dice"
    puts "- enter 'score' to skip remaining rolls and enter a score"
    puts "- to enter a score type code in brackets e.g. '1s' for ones"
    puts "- when you are ready to being enter 'start'"
    
    three_game_total = 0 # total score for all three games
    input = get_input(['start'], false) # wait for the user to enter 'start' (or 'quit)
    
    # loop for each of the three games
    for game_no in 1..NO_GAMES
      section_titles = ['UPPER SECTION', 'LOWER SECTION'].cycle
      section_columns = [1, 6].cycle # columns where the score is entered
      game_score = 0
      curr_column = 0 # declare here so it is in scope when writing grand total
      
      # for each section
      [UPPER_SECTIONS, LOWER_SECTIONS].each do |s|
        # create a copy of the commands in the current section as each command is removed
        # as it is used
        curr_sect = s.dup 
        
        curr_sect_title = section_titles.next
        
        # column of the grid where the score is entered
        curr_column = section_columns.next + game_no - 1
        section_total = 0
        for move in 1..curr_sect.length do
          # unfreeze all dice
          @dice.each { |d| d.set_frozen(false) }
          
          rolls_completed = 1
          roll_dice()
          @display.show
           
          # repeat sequence of 'freeze dice" until 3 rolls have been made
          # loop is ended by 'break' statement in case section when a score is entered
          while true do
            puts curr_sect_title + " - Move #{move}, Roll #{rolls_completed}"
            
            # only include 'r' command if less than 3 rolls have been made
            allowable_inputs = curr_sect + (rolls_completed < ROLLS_PER_GAME ? ['r'] : [])
            input = get_input(allowable_inputs, rolls_completed < ROLLS_PER_GAME ? true : false)
            
            case input
            when -> (inp) { curr_sect.include? inp } # section to score was selected
              # remove the selected command from the list of remaining inputs for the
              # section
              curr_sect -= [input]
              
              score = score_dice(input)
              section_total += score
              
              # write the score to the grid
              @grid.add_list([score.to_s], s.index(input) + 1, curr_column, @display)
              break # end the freeze dice, roll... loop when user enters a score
            when 'r'
              roll_dice()
              rolls_completed += 1
            else # numbers of dice to freeze were entered
              @dice.each_with_index { |d, i| d.toggle_frozen if input.include?(i + 1) }
            end   
                     
            @display.show
          end
        end
        
        # if in upper section calculate bonus and write to grid
        # (35 added if score for uppper is > 64)
        if curr_sect_title == 'UPPER SECTION'
          bonus = section_total >= 63 ? 35 : 0
          @grid.add_list([section_total.to_s, bonus.to_s], ROW_HEADINGS.index('SCORE'), curr_column, @display)
          section_total += bonus
        end
        
        # write the section total
        
        # assume 'UPPER TOTAL' and 'LOWER TOTAL' are on the same row
        total_row = ROW_HEADINGS.index('UPPER TOTAL')
        
        @grid.add_list([section_total.to_s], total_row, curr_column, @display)
        game_score += section_total
      end
      
      three_game_total += game_score
      
      total_row = COL5_HEADINGS.index('GRAND TOTAL') + 1 # write grand total to grid
      @grid.add_list([game_score.to_s], total_row, curr_column, @display)
      
      @display.show
      puts "Game #{game_no} complete, total score is #{game_score}."
      
      # prompt to start next game if at end of last one
      if game_no < NO_GAMES
        puts "Type 'start' when you're ready to start Game #{game_no + 1}"
        input = get_input(['start'], false)
      end
    end
    
    # load previous high score
    filename = 'cl_yhatzee_high_scores.txt'
    if File.exists?(filename)
      prev_high_score = File.read(filename).to_i
    else
      prev_high_score = 0
    end
    
    puts "Your total score for all three games was #{three_game_total}!"
    
    #write comparison of current score with loaded high score
    case
    when three_game_total > prev_high_score
      # save new high score
      File.open(filename, 'w') do |f|
        f.write three_game_total.to_s
        f.close
      end
      puts "NEW HIGH SCORE!!!"
      puts "This beats your previous high score of #{prev_high_score} by #{three_game_total - prev_high_score}." if prev_high_score != 0
    when three_game_total == prev_high_score
      puts "This equals your previous high score."
    when three_game_total < prev_high_score
      puts "Your current best is #{prev_high_score}."
    end
  end
  
  def get_input(comm_arr, nums_ok)    
    # While the user has not entered an allowable command display allowable commands and
    # prompt them again.
    # Allowable commands are:
    # - any of the commands in 'comm_arr'
    # - a string containing only digits (if nums_ok is true)
    # - quit
    
    # determine if string contains only numbers.  Note that numbers higher than the number
    # of dice are allowed but just ignored.
    error_made = false
    while true
      if error_made
        puts "Please enter one of the following commands: "
        puts comm_arr.join(' | ') + (nums_ok ? ' | die numbers e.g. "125"' : '') + ' | quit'
      end
      print "> "
      input = gets.chomp
      all_numbers = input.split('').all? { |n| n == '0' || n.to_i > 0 }
      break if (all_numbers && nums_ok) || comm_arr.include?(input) || input == 'quit'
      error_made = true
    end
    
    if input == 'quit'
      exit
    end
    
    # if user entered string containing only numbers then return an array of the numbers
    # else return the entered command
    return all_numbers ? (input.split('').map { |n| n.to_i }) : input
  end
  
  def roll_dice()
    @dice.each { |d| d.roll }
  end
  
  def score_dice(section)
    # create a sorted list of the dice numbers 
    dice_arr = @dice.map { |d| d.number }.sort!
    
    # if in upper section then just count the number of dice in the array that have the
    # same value as the selected one
    if UPPER_SECTIONS.include? section
      selection = section.to_i
      score = dice_arr.reduce(0) { |s, d| d == selection ? s += d : s }
    else
      # create an array containing the count of each dice value
      dice_count = [0, 0, 0, 0, 0, 0]
      dice_arr.each { |d| dice_count[d - 1] += 1 }
      no_of_kind = dice_count.max # maximum number of any die value
      score = 0
      case section
      when '3k', '4k', 'ch'
        if (section == '3k' && no_of_kind >= 3) ||
           (section == '4k' && no_of_kind >= 4) ||
            section == 'ch'
          score  = dice_arr.reduce(:+)
        end
      when 'fh'
        if dice_count.include?(3) && dice_count.include?(2)
          score = 25
        end
      when 'ls'
        if ([1, 2, 3, 4] - dice_arr).empty? ||
           ([2, 3, 4, 5] - dice_arr).empty? ||
           ([3, 4, 5, 6] - dice_arr).empty?
          score = 30
        end
      when 'hs'
        if ([1, 2, 3, 4, 5] - dice_arr).empty? ||
           ([2, 3, 4, 5, 6] - dice_arr).empty?
          score = 40
        end
      when 'yz'
        if no_of_kind == 5
          score = 50
        end
      end
      return score
    end
  end
end

Game.new