var Board = Class.extend({
  init: function(pieces){
    if(!pieces)
      this.build_board();
    else
      this.pieces = pieces;
  },
  build_board: function(){
    this.pieces = new Array(8);
    for (var i = 0; i < 8; i++) {
      this.pieces[i] = new Array(8);
    }
    this.add_pawns();
    this.add_rooks();
    this.add_knights();
    this.add_bishops();
    this.add_queens();
    this.add_kings();

    return ;
  },
  add_pawns: function(){
    var pawn = {
      board : this
    };
    for( var i = 0; i  < 8; i++)
    {
      black = {
        color : 'black',
        pos   : [1,i]
      };
      this.pieces[1][i] = new Pawn(mergeObj(pawn,black));
      white = {
        color : 'white',
        pos   : [6,i]
      };
      this.pieces[6][i] = new Pawn(mergeObj(pawn,white));
    }
  },
  add_rooks: function(){
    var positions = [[0,0], [0, 7], [7, 0], [7, 7]]
    var rook = {
      board : this
    };
    var color;
    for( var position in positions )
    {
      if (position[0] == 0)
        color = 'black';
      else
        color = 'white'

      rook = mergeObj(rook,{ color : color, pos : position});

      this.pieces[position[0]][position[1]] = new Rook(rook);
    }
  },
  add_knights: function(){
    var positions = [[0,1], [0, 6], [7, 1], [7, 6]]
    var knight = {
      board : this
    };
    var color;
    for( var position in positions )
    {
      if (position[0] == 0)
        color = 'black';
      else
        color = 'white'

      knight = mergeObj(knight,{ color : color, pos : position});

      this.pieces[position[0]][position[1]] = new Knight(knight);
    }
  },
  add_knights: function(){
    var positions = [[0,1], [0, 6], [7, 1], [7, 6]]
    var knight = {
      board : this
    };
    var color;
    for( var position in positions )
    {
      if (position[0] == 0)
        color = 'black';
      else
        color = 'white'

      knight = mergeObj(knight,{ color : color, pos : position});

      this.pieces[position[0]][position[1]] = new Knight(knight);
    }
  },
  queened_check: function(piece) {
    if (!(piece instanceof Pawn)) {
      return piece;
    } else {
     var end_dest = piece.color == "black" ? 7 : 0;
     if (piece.pos[0] == end_dest) {
       this.pieces[pos[0]][pos[1]] = new Queen({board: this, pos: piece.pos, color: piece.color});
     }
    }
    return this.pieces[pos[0]][pos[1]];
  },
  move: function(start_pos, end_pos, checked_test) {
    var piece = this.pieces[start_pos[0]][start_pos[1]];
    var moves = piece.moves;
    if (arguments.length == 2) {
      moves = piece.valid_moves;
    }
    if (moves.indexOf(end_pos)) {
      if (arguments.length == 2) {
        this.castle_check(piece, end_pos);
      }
      this.passant_check(piece, end_pos);
      this.pieces[end_pos[0]][end_pos[1]] = piece;
      self.pieces[start_pos[0]][end_pos[1]] = null;
      piece.pos = end_pos;
      piece = this.queened_check(piece);
      this.last_moved = piece;
    } else {
      throw "Invalid Destination";
    }
    return true;
  },
  dup: function() {
    var duped_pieces = []
    for (var row in pieces) {
      for (var piece in row) {
        duped_pieces[piece.pos[0]][piece.pos[1]] = cloneObject(piece);
      }
    }
    return duped_pieces;
  },
  off_the_grid: function(pos) {
    return pos[0] < 0 || pos[0] > 7 || pos[1] < 0 || pos[1] > 7;
  }
});

function cloneObject(obj) {
    if (obj === null || typeof obj !== 'object') {
        return obj;
    }
    var temp = obj.constructor();
    for (var key in obj) {
        temp[key] = cloneObject(obj[key]);
    }
    return temp;
}