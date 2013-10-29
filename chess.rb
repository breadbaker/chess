class Piece
  attr_accessor :board
  def initialize(options)
    default = {

    }
    @board = options[:board]
    @color
    @name =

  end
  def moves

  end

  def move_into_check?(pos)
    new_board = self.board.dup

    return true if new_board.checked?
  end

end

class SlidingPiece < Piece

  def move_dirs
  end
  def moves
  end
end

class SteppingPiece < Piece
end

class Board
  def initialize
    @pieces = Array.new(8) { Array.new(8) }
  end

  def checked?(color)

  end

  def move(start_pos,end_pos)
  end
end

class Game
end

