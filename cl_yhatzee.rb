# 
#   UPPER SECTION | UG1 | UG2 | UG3  |  LOWER SECTION | LG1 | LG2 | LG3  
#  ---------------|----------------- | ---------------|-----------------
#   ones          |     |     |      |  3 of a kind   |     |     |     
#  ---------------|----------------- | ---------------|-----------------
#   twos          |     |     |      |  4 of a kind   |     |     |     
#  ---------------|----------------- | ---------------|-----------------
#   threes        |     |     |      |  full house    |     |     |     
#  ---------------|----------------- | ---------------|-----------------
#   fours         |     |     |      |  sh. straight  |     |     |     
#  ---------------|----------------- | ---------------|-----------------
#   fives         |     |     |      |  lg. straight  |     |     |     
#  ---------------|----------------- | ---------------|-----------------
#   sixes         |     |     |      |  Yahtzee       |     |     |     
#  ---------------|----------------- | ---------------|-----------------
#           SCORE |     |     |      |  Chance        |     |     |     
#  ---------------|----------------- | ---------------|-----------------
#           BONUS |     |     |      |                |     |     |     
#  ---------------|----------------- | =================================
#     UPPER TOTAL |     |     |      |    LOWER TOTAL |     |     |     
#  =====================================================================
#                                         GRAND TOTAL |     |     |     
#
#  *********   +-------+   *-------*   *-------*   *-------*   *-------*
#  * X   X *   | 0   0 |   | 0   0 |   | 0   0 |   | 0   0 |   | 0   0 |
#  * X   X *   | 0   0 |   | 0   0 |   | 0   0 |   | 0   0 |   | 0   0 |
#  * X   X *   | 0   0 |   | 0   0 |   | 0   0 |   | 0   0 |   | 0   0 |
#  *********   +-------+   *-------*   *-------*   *-------*   *-------*
#

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

  def reset()
    @d_mx = []
    @height.times { @d_mx.push(Array.new(@width, ' ')) }
  end
  
  def show()
    system('clear')
    i = 0
    @d_mx.each { |line| puts ($mj_debug ? i.to_s : '') + line.join; i += 1 }
  end

  def draw_line_vert(col, row_start=0, l=@height, char='|', overwrite=true)
    for row in row_start..(row_start + l - 1)
      a_char = @d_mx[row][col] == '-' ? '+' : char
      @d_mx[row][col] = a_char if @d_mx[row][col] == nil || overwrite
    end
  end

  def draw_line_hor(row, col_start=0, l=@width, char='-', overwrite=true)
    for col in col_start..(col_start + l - 1)
      a_char = @d_mx[row][col] == '|' ? '+' : char
      @d_mx[row][col] = a_char if @d_mx[row][col] == nil || overwrite
    end
  end
  
  def write_at(str, row, col_start)
    return if str == '' || str.nil?
    str_arr = str.split('')
    i = 0
    for col in col_start..(col_start + str.length - 1)
      @d_mx[row][col] = str_arr[i]
      i += 1
    end
  end
  
  def draw_box_at(row_start, col_start, width, height, char=nil, corner='+')
    corner = corner.nil? ? '+' : corner
    tb_row = corner + ((char.nil? ? '-' : char) * (width - 2)) + corner # top and bottom row
    mid_row = (char.nil? ? '|' : char) + (' ' * (width - 2)) + (char.nil? ? '|' : char) # middle row
    write_at(tb_row, row_start, col_start) # draw top row
    
    #draw middle rows
    for row in (row_start + 1)..(row_start + height - 2)
      write_at(mid_row, row, col_start)
    end
    
    write_at(tb_row, row_start + height - 1, col_start) # draw bottom row
  end
end

class Grid
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
    col = @col_widths[0..(col_i - 1)].reduce(:+) + col_i + @col + 2
    str_arr.reduce(0) do |i, s|
      display.write_at(str_arr[i], @row + (row_start + i) * 2 + 1, col)
      i += 1
    end
  end
  
  def draw_at(row, col, display)
    @row = row
    @col = col
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
    @row = row
    @col = col
    @width = 9
    @height = 5
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
    @display.draw_box_at(@row, @col, @width, @height, @frozen ? '*' : nil, @frozen ? '*' : nil)
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
  COL5_TITLES = [
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
    # Draw board grid
    @grid = Grid.new(COL_HEADINGS, ROW_HEADINGS)
    
    # initialize display
    @display = DisplayMatrix.new(@grid.width, @grid.height + 9)
    
    #  draw grid
    @grid.draw_at(1, 1, @display)
    @grid.add_list(COL5_TITLES, 1, 5, @display)
    
    # initialize dice
    @dice = []
    
    for i in 0..4
      @dice[i] = Die.new(25, 2 + 12 * i, @display)
    end
    
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
    
    three_game_total = 0
    
    input = get_input(['start'], false)
    
    for game_no in 1..3      
      section_titles = ['UPPER SECTION', 'LOWER SECTION'].cycle
      section_columns = [1, 6].cycle
      game_score = 0
      curr_column = 0
      [UPPER_SECTIONS, LOWER_SECTIONS].each do |s|
        curr_sect = s.dup
        curr_sect_title = section_titles.next
        curr_column = section_columns.next + game_no - 1
        section_total = 0
        for move in 1..curr_sect.length do
          @dice.each { |d| d.set_frozen(false) }
          # repeat sequence of 'roll freeze then freeze dice' twice
          for roll in 1..2  
            roll_dice()
            @display.show 
            puts curr_sect_title + " - Move #{move}, Roll #{roll}"
            input = get_input(['r', 'score'], true)
            case input
            when 'score'
              break
            when 'r'
              # do nothing, i.e. move to next itteration
            else
              @dice.each_with_index { |d, i| d.toggle_frozen if input.include?(i + 1) }
            end
          end
    
          # roll dice if user didn't request to score
          if input != 'score'
            roll_dice()
          end
          @display.show
    
          # select section to score
          puts curr_sect_title + " - Move #{move}, Roll #{roll}"
          puts "Select scoring box"
          input = get_input(curr_sect, false) 
          curr_sect -= [input]
          score = score_dice(input)
          section_total += score
          @grid.add_list([score.to_s], s.index(input) + 1, curr_column, @display)
          @display.show
        end
      
        if curr_sect_title == 'UPPER SECTION'
          bonus = section_total >= 63 ? 35 : 0
          @grid.add_list([section_total.to_s, bonus.to_s], 7, curr_column, @display)
          section_total += bonus
        end
      
        @grid.add_list([section_total.to_s], 9, curr_column, @display)
        game_score += section_total
      end
      three_game_total += game_score
      @grid.add_list([game_score.to_s], 10, curr_column, @display)
      @display.show
      puts "Game #{game_no} complete, total score is #{game_score}."
      puts "Type 'start' when you're ready to start Game #{game_no + 1}" if game_no < 3
    end
    puts "Your total score for all three games was #{three_game_total}!"
  end
  
  def get_input(comm_arr, nums_ok)
    print "> "
    input = gets.chomp
    
    while  !(all_numbers(input) && nums_ok) && !comm_arr.include?(input) && input != 'quit'
      puts "Please enter one of the following commands: "
      puts comm_arr.join(' | ') + (nums_ok ? ' | die numbers e.g. "125"' : '') + ' | quit'
      print "> "
      input = gets.chomp
    end
    
    if input == 'quit'
      exit
    end
    puts "input: #{input}"
    return nums_ok && all_numbers(input) ? str_to_numbers(input) : input
  end
  
  def roll_dice()
    @dice.each { |d| d.roll }
  end
  
  def score_dice(section)  
    dice_arr = get_dice_array().sort!
    
    if UPPER_SECTIONS.include? section
      selection = section.to_i
      score = dice_arr.reduce(0) { |s, d| d == selection ? s += d : s }
    else
      dice_count = [0, 0, 0, 0, 0, 0]
      dice_arr.each { |d| dice_count[d - 1] += 1 }
      no_of_kind = dice_count.max
      score = 0
      case section
      when '3k', '4k', 'ch'
        if (section == '3k' && no_of_kind >= 3) ||
           (section == '4k' && no_of_kind >= 4) ||
            section == 'ch'
          score  = get_dice_array().reduce(:+)
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
  
  def get_dice_array()
    @dice.map { |d| d.number }
  end
  
  def all_numbers(str)
    str.split('').all? { |n| n == '0' || n.to_i > 0 }
  end
  
  def str_to_numbers(str)
    str.split('').map { |n| n.to_i }
  end
end

Game.new