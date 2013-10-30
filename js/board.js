var Person = Class.extend({
  init: function(isDancing){
    this.dancing = isDancing;
  }
});

var Ninja = Person.extend({
  init: function(){
    this._super( false );
  }
});

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

});