using MachineLearning
using ReinforcementLearning

hidden_layers = [100]
learning_rate = 500.0
num_games     = 500_000

println("Hidden Layers: ", hidden_layers)
println("Learning Rate: ", learning_rate)
println("Num Games:     ", num_games)

@time q_net, q_net_player = train_q_net_player(play_connect_four_track_state,
                                               84,
                                               [random_player],
                                               num_games=num_games,
                                               net_options=regression_net_options(hidden_layers=hidden_layers,
                                                                                  regularization_factor=0.0,
                                                                                  learning_rate=learning_rate))
@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, random_player, 2_000)
println("qnet v rand: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, make_lookahead_player(1), 2_000)
println("qnet v lh1:  ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, make_lookahead_player(2), 400)
println("qnet v lh2:  ", results_txt)
