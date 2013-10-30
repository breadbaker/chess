var Game = Class.extend({
  init: function(options) {
    this.board = new Board();
  },
  play: function() {

  }
});

g = new Game();
console.log(g.board.to_s());