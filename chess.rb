require 'colorize'
class Piece
  attr_accessor :board, :color, :name, :move_coords, :pos
  def initialize(options)
    @board = options[:board]
    @color = options[:color]
    @name = options[:name]
    @pos = options[:pos]
    @move_coords = []
  end

  def valid_moves
    moves.select do |move|
      !move_into_check?(move)
    end
  end

  def move_into_check?(pos)
    new_board = Board.new(self.board.dup)
    new_board.move(self.pos,pos)
    return true if new_board.checked?(self.color)
  end
end

class InvalidMoveException < StandardError
end

class SlidingPiece < Piece
  def move_dirs(cord)

    moves = []
    i =  1
    while true
      pos = [self.pos[0] + (cord[0]* i), self.pos[1] + (cord[1] * i)]
      break if self.board.off_the_grid?(pos)
      hit_piece = self.board.pieces[pos[0]][pos[1]]
      if !hit_piece.nil?
        moves << pos if hit_piece.color != self.color
        break
      end
      moves << pos
      i += 1
    end

    moves
  end

  def moves
    self.move_coords.inject([]) do |moves,dir|
      moves + move_dirs(dir)
    end
  end
end

class SteppingPiece < Piece
  def moves
    self.move_coords.map do |move|
      [pos[0] + move[0],pos[1] + move[1]]
    end.select do |move|
      next if self.board.off_the_grid?(move)
      space = self.board.pieces[move[0]][move[1]]
      space.nil? || space.color != self.color
    end
  end
end

class Pawn < SteppingPiece
  def to_s
    self.color == :white ? "\u2659" : "\u265F"
  end
  def moves
    moves = []

    [[1,1],[1,-1]].each do |attack|
      attack[0] = -attack[0] if self.color == :white
      space = self.board.pieces[pos[0] + attack[0]][pos[1] + attack[1]]
      moves << [pos[0] + attack[0],pos[1] + attack[1]] unless space.nil? || space.color == self.color
    end

    steps = [[1,0]]
    steps << [2,0] if self.color == :white && self.pos[0] == 6
    steps << [2,0] if self.color == :black && self.pos[0] == 1

    steps.each do |move|
      move[0] = -move[0] if self.color == :white
      space = self.board.pieces[pos[0] + move[0]][pos[1] + move[1]]
      moves << [pos[0] + move[0],pos[1] + move[1]] if space.nil?
    end


    moves
  end
end

class Knight < SteppingPiece
  KNIGHT_MOVES = [[1,2],[-1,2],[1,-2],
    [-1,-2],[2,1],[-2,1],[-2,-1],[2,-1]]

  def initialize(options)
    super
    @move_coords = KNIGHT_MOVES
  end

  def to_s
    self.color == :white ? "\u2658" : "\u265E"
  end
end

class King < SteppingPiece
  KING_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1],
    [1, 1], [-1, 1], [-1, -1], [1, -1]]

  def initialize(options)
    super
    @move_coords = KING_MOVES
  end

  def to_s
    self.color == :white ? "\u2654" : "\u265A"
  end
end

class Bishop < SlidingPiece
  BISHOP_MOVES = [[1, 1], [-1, 1], [-1, -1], [1, -1]]

  def initialize(options)
    super
    @move_coords = BISHOP_MOVES
  end

  def to_s
    self.color == :white ? "\u2657" : "\u265D"
  end
end

class Rook < SlidingPiece
  ROOKIE_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1]]

  def initialize(options)
    super
    @move_coords = ROOKIE_MOVES
  end

  def to_s
    self.color == :white ? "\u2656" : "\u265C"
  end
end

class Queen < SlidingPiece
  QUEEN_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1],
    [1, 1], [-1, 1], [-1, -1], [1, -1]]

  def initialize(options)
    super
    @move_coords = QUEEN_MOVES
  end

  def to_s
    self.color == :white ? "\u2655" : "\u265B"
  end
end

class Board
  attr_accessor :pieces
  def initialize(pieces=nil)
    @pieces = pieces
    build_board if pieces.nil?
  end

  def build_board
    self.pieces = Array.new(8) { Array.new(8) }
    add_pawns
    add_rooks
    add_knights
    add_bishops
    add_queens
    add_kings
  end

  def add_pawns
    pawn = {
      :board  => self
    }
    8.times do |i|
      black = {
        :color  => :black,
        :pos    => [1,i]
      }
      self.pieces[1][i] = Pawn.new(pawn.merge(black))
      white = {
        :color  => :white,
        :pos    => [6,i]
      }
      self.pieces[6][i] = Pawn.new(pawn.merge(white))
    end
  end

  def add_rooks
    positions = [[0,0], [0, 7], [7, 0], [7, 7]]
    rook = {
      :board  =>  self
    }
    positions.each do |pos|
      rook = rook.merge({:color => pos[0] == 0 ? :black : :white, :pos => pos})
      self.pieces[pos[0]][pos[1]] = Rook.new(rook)
    end
  end

  def add_knights
    positions = [[0,1], [0, 6], [7, 1], [7, 6]]
    knight = {
      :board  =>  self
    }
    positions.each do |pos|
      knight = knight.merge({:color => pos[0] == 0 ? :black : :white, :pos => pos})
      self.pieces[pos[0]][pos[1]] = Knight.new(knight)
    end
  end

  def add_bishops
    positions = [[0,2], [0, 5], [7, 2], [7, 5]]
    bishop = {
      :board  =>  self
    }
    positions.each do |pos|
      bishop = bishop.merge({:color => pos[0] == 0 ? :black : :white, :pos => pos})
      self.pieces[pos[0]][pos[1]] = Bishop.new(bishop)
    end
  end

  def add_queens
    positions = [[0,3], [7, 3]]
    queen = {
      :board  =>  self
    }
    positions.each do |pos|
      queen = queen.merge({:color => pos[0] == 0 ? :black : :white, :pos => pos})
      self.pieces[pos[0]][pos[1]] = Queen.new(queen)
    end
  end

  def add_kings
    positions = [[0,4], [7, 4]]
    king = {
      :board  =>  self
    }
    positions.each do |pos|
      king = king.merge({:color => pos[0] == 0 ? :black : :white, :pos => pos})
      self.pieces[pos[0]][pos[1]] = King.new(king)
    end
  end

  def to_s
    yellow = true
    str = ""
    letter_str = "   "
    ("A".."H").to_a.each do |l|
      letter_str += l.rjust(3)
      letter_str += "".rjust(2)
    end
    str += "#{letter_str}\n"
    self.pieces.each_with_index do |row, idx|
      row_str = "#{8 - idx}  "
      row.each do |piece|
        row_str += display_piece(piece).rjust(3).colorize(:background => yellow ? :light_yellow : :light_red)
        row_str += "".rjust(2).colorize(:background => yellow ? :light_yellow : :light_red)
        yellow = !yellow
      end
      str += "#{row_str}\n"
      yellow = !yellow
    end

    str
  end

  def display_piece(piece)
    return ' ' if piece.nil?
    piece.to_s
  end

  def is_color?(pos,color)
    piece = self.pieces[pos[0]][pos[1]]
    if piece.nil? || piece.color != color
      raise InvalidMoveException, "That's not your piece"
    end
  end

  def checked?(color)
    pieces.flatten.compact.select do |piece|
      piece.color != color && piece.moves.include?(king(color).pos)
    end.size > 0
  end

  def checkmate?(color)
    pieces.flatten.compact.select do |piece|
      if piece.color == color && !piece.valid_moves.empty?
        return false
      end
    end

    true
  end

  def king(color)
    pieces.flatten.select do |piece|
      piece.is_a?(King) && piece.color == color
    end.first
  end

  def move(start_pos,end_pos)

    piece = self.pieces[start_pos[0]][start_pos[1]]
    if piece.moves.include?(end_pos)
      self.pieces[end_pos[0]][end_pos[1]] = piece
      self.pieces[start_pos[0]][start_pos[1]] = nil
      piece.pos = end_pos
    else
      raise InvalidMoveException, "Invalid Destination"
    end
  end

  def dup
    self.pieces.deep_dup
  end

  def off_the_grid?(pos)
    pos[0] > 7 || pos[0] < 0 || pos[1] > 7 || pos[1] < 0
  end
end

class Array
  def deep_dup
    self.map { |el| el.is_a?(Array) ? el.deep_dup : (el.nil? ? nil : el.dup) }
  end
end

class Game
  attr_accessor :board, :white, :black
  def initialize
    @board = Board.new
    @white = HumanPlayer.new
    @black = HumanPlayer.new
    play_loop
  end

  def play_loop
    puts "Welcome to our game of Chess."
    puts "You make moves by typing in the coordinate that you wish to move from, followed by the coordinate you're moving to"

    turn = :white

    until board.checkmate?(turn)
      white_turn = turn == :white
      player = white_turn ? @white : @black
      puts self.board
      puts "#{turn.to_s.capitalize}'s turn".bold
      begin
        start_pos, end_pos = player.play_turn
        board.is_color?(start_pos,turn)
        self.board.move(start_pos, end_pos)
      rescue InvalidMoveException => e
        puts e.message
        retry
      end
      turn = white_turn ? :black : :white
    end

    if board.checked?(:black)
      puts "Checkmate! White Wins!".bold
    elsif board.checked?(:white)
      puts "Checkmate! Black Wins!".bold
    else
      puts "Stalemate. No one wins!".bold
    end
  end
end

class HumanPlayer
  LETTER_HASH = {:a => 0, :b => 1, :c => 2, :d => 3,
    :e => 4, :f => 5, :g => 6, :h => 7}
  def play_turn
    puts "Where do you want to move?"
    input = gets.chomp

    start_coord, end_coord = input.split(" ")

    start_pos = start_coord.split("")
    end_pos = end_coord.split("")

    start_pos[1] = 8 - start_pos[1].to_i
    start_pos[0] = LETTER_HASH[start_pos[0].to_sym]

    end_pos[1] = 8 - end_pos[1].to_i
    end_pos[0] = LETTER_HASH[end_pos[0].to_sym]

    start_pos[0],start_pos[1] = start_pos[1],start_pos[0]
    end_pos[0],end_pos[1] = end_pos[1],end_pos[0]

    [start_pos, end_pos]
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new
end