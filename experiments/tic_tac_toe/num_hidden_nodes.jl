using ReinforcementLearning

for num_hidden_nodes=[2, 5, 10, 20, 50, 100, 200, 500, 1000]
    println("Number of Hidden Nodes: ", num_hidden_nodes)
    for sample=1:5        
        q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                                 18,
                                                 [random_player, perfect_player],
                                                 hidden_layers=[num_hidden_nodes], num_games=50_000)
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 10_000)
        println("Q net vs random: ", results_txt)
    end
end