using Gadfly
using ReinforcementLearning

q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                         18,
                                         [random_player, perfect_player],
                                         hidden_layers=[50], num_games=50_000)
win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 1_000)
println(results_txt)

for i=1:size(q_net.layers[1].weights, 1)
    l = plot_tic_tac_toe_neuron(vec(q_net.layers[1].weights[i,2:end]))
    draw(PNG(@sprintf("plots/neuron_%i.png", i), 8inch, 6inch), plot(l,
        Guide.title(@sprintf("Neuron %i weight: %0.4f", i, q_net.layers[2].weights[i]))))
end
