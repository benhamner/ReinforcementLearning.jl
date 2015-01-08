using MachineLearning
using ReinforcementLearning

hidden_layers = [100]
learning_rate = 500.0
num_games     = 200_000

println("Hidden Layers: ", hidden_layers)
println("Learning Rate: ", learning_rate)
println("Num Games:     ", num_games)

@time q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                               18,
                                               [random_player, perfect_player],
                                               num_games=num_games,
                                               net_options=regression_net_options(hidden_layers=hidden_layers,
                                                                                  regularization_factor=0.0,
                                                                                  learning_rate=learning_rate))
@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 2_000)
println("qnet v rand: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, q_net_player, 2_000)
println("qnet v qnet: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, perfect_player, 2_000)
println("qnet v perf: ", results_txt)
