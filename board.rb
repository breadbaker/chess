class Board
  attr_accessor :pieces, :last_moved
  def initialize(pieces=nil)
    @pieces = pieces
    build_board if pieces.nil?
    @last_moved = nil
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

  def passant_check(piece,end_pos)
    if piece.is_a?(Pawn)
      piece.passant = true if (piece.pos[0]-end_pos[0]).abs == 2
      last = self.last_moved
      if last.is_a?(Pawn) && last.passant && (last.pos[1]-piece.pos[1]).abs == 1
        if (piece.color == :black && piece.pos[0] == 4) || piece.color == :white && piece.pos[0] == 3
          self.pieces[last.pos[0]][last.pos[1]] = nil
        end
      end
    end
  end

  def move(start_pos,end_pos)
    piece = self.pieces[start_pos[0]][start_pos[1]]
    if piece.moves.include?(end_pos)
      passant_check(piece,end_pos)
      self.pieces[end_pos[0]][end_pos[1]] = piece
      self.pieces[start_pos[0]][start_pos[1]] = nil
      piece.pos = end_pos
      self.last_moved = piece
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