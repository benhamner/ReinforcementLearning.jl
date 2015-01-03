using ReinforcementLearning

@time q_net, q_net_player = train_q_net_player(play_connect_four_track_state,
                                               84,
                                               [random_player, make_lookahead_player(1), make_lookahead_player(2)],
                                               num_games=10_000)
@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, random_player, 200)
println("Q net vs random: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, make_lookahead_player(1), 200)
println("Q net vs ahead1: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, make_lookahead_player(2), 200)
println("Q net vs ahead2: ", results_txt)

@time q_net, q_net_player = train_q_net_player(play_connect_four_track_state,
                                               84,
                                               [random_player, make_lookahead_player(1), make_lookahead_player(2), make_lookahead_player(3)],
                                               num_games=50_000)
@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, random_player, 200)
println("Q net vs random: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, make_lookahead_player(1), 200)
println("Q net vs ahead1: ", results_txt)

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_net_player, make_lookahead_player(2), 200)
println("Q net vs ahead2: ", results_txt)
