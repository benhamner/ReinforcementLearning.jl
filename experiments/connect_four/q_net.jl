using ReinforcementLearning

@time q_net, q_net_player = train_q_net_player(play_connect_four_track_state,
                                               84,
                                               [random_player],
                                               num_games=100_000,
                                               hidden_layers=[100,100,20,20])
@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, random_player, 1_000)
println("Q net vs random: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, make_lookahead_player(1), 1_000)
println("Q net vs ahead1: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, make_lookahead_player(2), 1_000)
println("Q net vs ahead2: ", results_txt)
