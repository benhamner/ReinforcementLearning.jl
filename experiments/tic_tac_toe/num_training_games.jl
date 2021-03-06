using ReinforcementLearning

for num_games=[1_000, 10_000, 100_000, 1_000_000, 10_000_000]
    println("Number of Games: ", num_games)
    for sample=1:1        
        q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                                 18,
                                                 [random_player, perfect_player],
                                                 num_games=num_games,
                                                 hidden_layers=[20])
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 10_000)
        println("Q net vs random: ", results_txt)
    end
end