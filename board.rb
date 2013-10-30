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

  def castle_check(piece, end_pos)
    if piece.is_a?(King)
      if (end_pos[1]-piece.pos[1]).abs == 2
        raise InvalidMoveException, "You can't castle once you've moved your King" if piece.moved
        raise InvalidMoveException, "You can't castle if you're in check." if checked?(piece.color)
        direction = end_pos[1] - piece.pos[1] > 0 ? 7 : 0
        pieces_between = [[piece.pos[0], piece.pos[1] + (direction == 7 ? 1 : -1)],
          [piece.pos[0], piece.pos[1] + (direction == 7 ? 2 : -2)]]
        target_rook = self.pieces[end_pos[0]][direction]
        if (target_rook.nil? || !target_rook.is_a?(Rook) || target_rook.moved)
          raise InvalidMoveException, "You can't castle in that direction because your rook has already moved"
        end
        pieces_between.each do |between|
          raise InvalidMoveException, "You can't move through or into checkw while castling." if piece.move_into_check?(between)
          raise InvalidMoveException, "You can't castle because there's a piece in the way." unless self.pieces[between[0]][between[1]].nil?
        end
        self.pieces[pieces_between[0][0]][pieces_between[0][1]] = target_rook
        self.pieces[target_rook.pos[0]][target_rook.pos[1]] = nil
        target_rook.pos = [pieces_between[0][0], pieces_between[0][1]]
        puts "Castled!"
      end
      piece.moved = true
    elsif piece.is_a?(Rook)
      piece.moved = true
    end
  end

  def queened_check(piece)
    return piece unless piece.is_a?(Pawn)
    end_dest = piece.color == :black ? 7 : 0
    if piece.pos[0] == end_dest
      self.pieces[piece.pos[0]][piece.pos[1]] = Queen.new ({
        :board  =>  self,
        :pos    =>  piece.pos,
        :color  =>  piece.color
      })
    end

    self.pieces[piece.pos[0]][piece.pos[1]]
  end

  def move(start_pos,end_pos, checked_test)
    piece = self.pieces[start_pos[0]][start_pos[1]]
    moves = piece.moves
    moves = piece.valid_moves unless checked_test
    if moves.include?(end_pos)
      castle_check(piece, end_pos) unless checked_test
      passant_check(piece,end_pos)
      self.pieces[end_pos[0]][end_pos[1]] = piece
      self.pieces[start_pos[0]][start_pos[1]] = nil
      piece.pos = end_pos
      piece = queened_check(piece)
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