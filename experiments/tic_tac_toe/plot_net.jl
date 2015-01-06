using Gadfly
using MachineLearning
using ReinforcementLearning

q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                         18,
                                         [random_player, perfect_player],
                                         num_games=10_000,
                                         net_options=regression_net_options(hidden_layers=[50], regularization_factor=0.0, learning_rate=100.0))
win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 1_000)
println("Qnet v Random:  ", results_txt)
win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, q_net_player, 1_000)
println("Qnet v Qnet:    ", results_txt)
win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, perfect_player, 1_000)
println("Qnet v perfect: ", results_txt)

for i=1:size(q_net.layers[1].weights, 1)
    l = plot_tic_tac_toe_neuron(vec(q_net.layers[1].weights[i,2:end]))
    draw(PNG(@sprintf("plots/neuron_%i.png", i), 8inch, 6inch), plot(l,
        Guide.title(@sprintf("Neuron %i weight: %0.4f", i, q_net.layers[2].weights[i]))))
end
