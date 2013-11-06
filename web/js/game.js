var Game = Class.extend({
  init: function(options) {
    this.board = new Board();

    this.player = new Player(this);

    this.turn = 'white';
    this.play();
  },
  play: function() {
    alert('welcome to chess.  it is whites turn click the piece you want to move.   then the place you want to move it. no backsies.');
    this.board.render();
  }
});

var Player = Class.extend({
  init: function(game){
    var that = this;
    var pickedPiece = false;
    var startCoord = [];
    var endCoord = []
    $(".square").on('click', function(e) {
      var row = $(this).parent().index();
      var column = $(this).index();
      pickedPiece = !pickedPiece;
      if (pickedPiece) {
        startCoord = [row, column];
      } else {
        endCoord = [row, column];
      }
    });
  }
});
var g = new Game();
/*
class Game
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
        input = player.play_turn

        case input[:action]
        when :save
          save
        when :load
          load
        else
          board.is_color?(input[:start_pos],turn)
          self.board.move(input[:start_pos], input[:end_pos])
        end
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
    if input.include?('l')
      return {:action =>  :load}
    elsif input.include?('s')
      return {:action =>  :save}
    end
    start_coord, end_coord = input.split(" ")

    start_pos = start_coord.split("")
    end_pos = end_coord.split("")

    start_pos[1] = 8 - start_pos[1].to_i
    start_pos[0] = LETTER_HASH[start_pos[0].to_sym]

    end_pos[1] = 8 - end_pos[1].to_i
    end_pos[0] = LETTER_HASH[end_pos[0].to_sym]

    start_pos[0],start_pos[1] = start_pos[1],start_pos[0]
    end_pos[0],end_pos[1] = end_pos[1],end_pos[0]

    { :start_pos  =>  start_pos,
      :end_pos    =>  end_pos,
      :action     =>  :move}
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new
end
*/