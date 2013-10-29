class Piece
  attr_accessor :board, :color, :name, :moves
  def initialize(options)
    @board = options[:board]
    @color = options[:color]
    @name = options[:name]
    @pos = options[:pos]
    @moves = []
  end

  def moves

  end

  def move_into_check?(pos)
    new_board = self.board.dup

    return true if new_board.checked?
  end

end

class SlidingPiece < Piece
  def move_dirs(cord)
    cord[0],cord[1]
    moves = []
    i =  1
    while true
      pos = [pos[0]+  cord[0]* i, pos[1] + cord[1]*i]
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
    self.moves.inject([]) do |moves,dir|
      moves + move_dirs(dir)
    end
  end
end

class SteppingPiece < Piece
  def moves
    self.moves.select do |move|
      space = self.board.pieces[pos[0] + move[0]][pos[1] + move[1]]
      space.nil? || space.color != self.color
    end
  end
end

class Pawn < SteppingPiece
  def initialize
    super
  end

  def moves
    moves = []

    [[1,1],[1,-1]].each do |attack|
      attack[0] = -attack[0] if self.color == :white
      space = self.board.pieces[pos[0] + attack[0]][pos[1] + attack[1]]
      moves << attack unless space.nil? || space.color == self.color
    end

    [[1,0],[2,0]].each do |move|
      move[0] = -move[0] if self.color == :white
      space = self.board.pieces[pos[0] + move[0]][pos[1] + move[1]]
      moves << move if space.nil?
    end

    moves
  end
end

class Knight < SteppingPiece
  def initialize
    super
    @moves = [[1,2],[-1,2],[1,-2],[-1,-2],
            [2,1],[-2,1],[-2,-1],[2,-1]]
  end
end

class King < SteppingPiece
  def initialize
    super
    @moves = [[1, 0], [0, 1], [-1, 0], [0, -1],
      [1, 1], [-1, 1], [-1, -1], [1, -1]]
  end
end

class Bishop < SlidingPiece
  def initialize
    super
    @moves = [[1, 1], [-1, 1], [-1, -1], [1, -1]]
  end
end

class Rook < SlidingPiece
  def initialize
    super
    @moves = [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end
end

class Queen < SlidingPiece
  def initialize
    super
    @moves = [[1, 0], [0, 1], [-1, 0], [0, -1],
      [1, 1], [-1, 1], [-1, -1], [1, -1]]
  end
end

class Board
  attr_accessor :pieces
  UNICODE_SYMBOLS = {
    :black  =>  {
      :king   => "\u265A",
      :queen  => "\u265B",
      :rook   => "\u265C",
      :bishop => "\u265D",
      :knight => "\u265E",
      :pawn   => "\u265F"
    },
    :white  =>  {
      :king   => "\u2654",
      :queen  => "\u2655",
      :rook   => "\u2656",
      :bishop => "\u2657",
      :knight => "\u2658",
      :pawn   => "\u2659"
    }
  }
  def initialize
    @pieces = Array.new(8) { Array.new(8) }
    build_board
  end

  def build_board
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

  def display
    self.pieces.each do |row|
      row_str = ""
      row.each do |piece|
        row_str += display_piece(piece)
      end
      puts row_str
    end
  end

  def display_piece(piece)
    return ' ' if piece.nil?
    name = piece.class.class_name.downcase.to_sym
    UNICODE_SYMBOLS[piece.color][name]
  end

  def checked?(color)

  end

  def move(start_pos,end_pos)
  end
end

class Game

end

