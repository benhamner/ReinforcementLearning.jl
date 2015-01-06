using Gadfly
using MachineLearning
using ReinforcementLearning

learning_rates  = Float64[]
win_percentages = Float64[]

for sample=1:10
    for learning_rate = [0.1,0.5,1.0,5.0,10.0,50.0,100.0]
        println("Learning Rate: ", learning_rate)
        q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                                 18,
                                                 [random_player, perfect_player],
                                                 num_games=10_000,
                                                 net_options=regression_net_options(hidden_layers=[50], regularization_factor=0.0, learning_rate=learning_rate))
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 1_000)
        println("Qnet v Random:  ", results_txt)
        push!(learning_rates, learning_rate)
        push!(win_percentages, win_percentage)
        data = DataFrame(LearningRate=learning_rates, WinPercent=win_percentages)
        p = plot(data, x=:LearningRate, y=:WinPercent, Geom.point)
        draw(PNG("plots/learning_rate.png", 8inch, 6inch), p)
    end
end
