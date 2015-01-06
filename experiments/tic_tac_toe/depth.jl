using MachineLearning
using ReinforcementLearning

for depth=1:10
    println("Depth: ", depth)
    for sample=1:2        
        q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                                 18,
                                                 [random_player, perfect_player],
                                                 num_games=50_000,
                                                 net_options=regression_net_options(hidden_layers=[20 for i=1:depth], regularization_factor=0.0))
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 10_000)
        println("Q net vs random: ", results_txt)
    end
end
