var Piece = Class.extend({
  init: function(options) {
    this.board = options.board;
    this.color = options.color;
    this.pos = options.pos;
  },
  valid_moves: function(){
    var moves = this.moves();
    var valid_moves = [];
    for (var move in moves) {
      if (!this.move_into_check(move))
        valid_moves.push(move);
    }
    return valid_moves;
  },
  move_into_check : function(pos) {
    var new_board = new Board(this.board.dup());
    new_board.move(this.pos, pos, true);
    return new_board.checked(this.color);
  }
});

var SlidingPiece = Piece.extend({
  move_dirs: function(cord) {
    var moves = [];
    var i = 1;
    while (true) {
      var pos = [this.pos[0] + (cord[0] * i), this.pos[1] + (cord[1] * i)];
      if (this.board.off_the_grid(pos)) {
        break;
      }
      var hit_piece = this.board.pieces[pos[0]][pos[1]];
      if (hit_piece) {
        if (hit_piece.color != this.color) {
          moves.push(pos);
          break;
        }
      }
      moves.push(pos);
      i++;
    }
    return moves;
  },
  moves: function() {
    var moves = [];
    var coords = this.move_coords;
    for (var move in coords) {
      moves.push(this.move_dirs(move));
    }
    return moves;
  }
});

var SteppingPiece = Piece.extend({
  moves: function() {
    var move_arr = [];
    for (var move in this.move_coords) {
      var x = move[0] + this.pos[0];
      var y = move[1] + this.pos[1];
      move_arr.push([x, y]);
    }
    var ret_arr = [];
    for (var mv in move_arr) {
      if (!this.board.off_the_grid(mv)) {
        var space = this.board.pieces[mv[0]][mv[1]];
        if (!space || space.color != this.color) {
        	ret_arr.push(space.pos);
        }
      }
    }
    return move_arr;
  }
});

var Pawn = SteppingPiece.extend({
  init: function(options) {
    var that = this._super(options);
    that.passant = false;
    return that;
  },
  to_s: function() {
    return this.color == "white" ? "\u2659" : "\u265F";
  },
  moves: function() {
    var moves = [];
    var attack_arr = [[1,1], [1,-1]];
    for (var attack in attack_arr) {
      if (this.color == "white") {
        attack[0] = -attack[0];
      }
      var space = this.board.pieces[this.pos[0] + attack[0]][this.pos[1] + attack[1]];
      if (space && space.color != this.color) {
        moves.push([this.pos[0] + attack[0], this.pos[1] + attack[1]]);
      }
    }
    var last = this.board.last_moved;
    if (last instanceof Pawn && last.passant && Math.abs((last.pos[1]-this.pos[1])) == 1) {
      if (this.color == "black" && this.pos[0] == 4) {
        moves.push([last.pos[0]+1,last.pos[1]]);
      } else if (this.color == "white" && this.pos[0] == 3) {
        moves.push([last.pos[0]-1,last.pos[1]]);
      }
    }
    var steps = [[1, 0]];
    if ((this.color == "white" && this.pos[0] == 6) || (this.color == "black" && this.pos[1] == 1)) {
      steps.push([2,0]);
    }
    for (var step in steps) {
      if (this.color == "white") {
        step[0] = -(step[0]);
      }
      var space = this.board.pieces[this.pos[0] + step[0]][this.pos[1] + step[1]];
      if (!space) {
        moves.push[this.pos[0] + step[0],this.pos[1] + step[1]];
      }
    }
    return moves;
   }
});

var Knight = SteppingPiece.extend({
    init: function(options) {
      var that = this._super(options);
      that.move_coords = [[1,2],[-1,2],[1,-2],
    [-1,-2],[2,1],[-2,1],[-2,-1],[2,-1]];
    },

    to_s: function() {
      return this.color == "white" ? "\u2658" : "\u265E";
    }
});
class King < SteppingPiece
  attr_accessor :moved
  KING_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1],
    [1, 1], [-1, 1], [-1, -1], [1, -1], [0, 2], [0, -2]]

  def initialize(options)
    super
    @move_coords = KING_MOVES
    @moved = false
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
  attr_accessor :moved
  ROOKIE_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1]]

  def initialize(options)
    super
    @moved = false
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

var Queen = function() {};
Queen.prototype = {
  var QUEEN_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1],
    [1, 1], [-1, 1], [-1, -1], [1, -1]];

};