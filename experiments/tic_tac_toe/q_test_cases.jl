using MachineLearning
using ReinforcementLearning

n, n_player = train_q_net_player(play_tic_tac_toe_track_state,
                                 18,
                                 [random_player],
                                 num_games=5_000,
                                 net_options=regression_net_options(hidden_layers=[100],
                                                                    regularization_factor=0.0,
                                                                    learning_rate=1_000.0),
                                 self_play=true,
                                 alpha = .5)

q, q_player = train_q_learning_player([random_player],
                                      num_games=5_000,
                                      alpha=0.5,
                                      self_play=true)

function score_moves_net(game, player)
    moves = possible_moves(game)
    for move=moves
        score = predict(n, game_to_input_features(game, player, move))
        println("Move: ", move, " Score: ", score)
    end
end

function score_moves_q(game, player)
    moves = possible_moves(game)
    for move=moves
        score = q[(game, player, move)]
        println("Move: ", move, " Score: ", score)
    end
end

println(board_to_string(TicTacToe([1,1,0,2,2,0,0,0,0])))
println("Net: ")
score_moves_net(TicTacToe([1,1,0,2,2,0,0,0,0]), 1)
println("Perfect: ")
score_moves_q(TicTacToe([1,1,0,2,2,0,0,0,0]), 1)
