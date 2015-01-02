abstract Game

int_to_string(x::Int) = x==0 ? " " : (x==1 ? "X" : "O")
random_player(game::Game, player::Int) = rand(possible_moves(game))
