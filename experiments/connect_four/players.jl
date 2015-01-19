using Gadfly
using MachineLearning
using ReinforcementLearning

hidden_layers = [25]
learning_rate = 500.0
num_games     = 1_000

println("Hidden Layers: ", hidden_layers)
println("Learning Rate: ", learning_rate)
println("Num Games:     ", num_games)

res = DataFrame(Name=[], Opponent=[], Iteration=[], WinPercentage=[], DrawPercentage=[], LossPercentage=[])
iterations=10
base_players = Vector{Function}[[], [random_player], [random_player], [random_player, make_lookahead_player(1)]]
base_player_names = ["Self", "Rand", "Rand+Self", "Rand+Self+LH1"]
play_self = [true, false, true, true]

train_functions = vcat([() -> train_q_net_player(play_connect_four_track_state,
                                                 84,
                                                 base_players[i],
                                                 num_games=num_games,
                                                 net_options=regression_net_options(hidden_layers=hidden_layers,
                                                                                    regularization_factor=0.0,
                                                                                    learning_rate=learning_rate),
                                                 self_play=play_self[i],
                                                 alpha=0.75) for i=1:length(base_players)],
                       [() -> train_q_net_player(play_connect_four_track_state,
                                                 84,
                                                 base_players[i],
                                                 num_games=num_games,
                                                 net_options=regression_net_options(hidden_layers=hidden_layers,
                                                                                    regularization_factor=0.0,
                                                                                    learning_rate=learning_rate),
                                                 self_play=play_self[i],
                                                 alpha=0.25) for i=1:length(base_players)])
player_names = vcat(["A0.75"*n for n=base_player_names],["A0.25"*n for n=base_player_names])

evaluation_opponents = [random_player, make_lookahead_player(1), make_lookahead_player(2)]
evaluation_opponent_names = ["rand", "lh1", "lh2"]

for iteration=1:iterations
    println("Iteration: ", iteration)
    for i_train_function=1:length(train_functions)
        q, q_player = train_functions[i_train_function]()
        for i_opponent = 1:length(evaluation_opponents)
            win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_player, evaluation_opponents[i_opponent], 100)
            opponent_name = evaluation_opponent_names[i_opponent]
            res = vcat(res, DataFrame(Name=player_names[i_train_function], Opponent=opponent_name, Iteration=iteration, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
            println("qnet v ", opponent_name, ": ", results_txt)
        end
    end
    for i_opponent = 1:length(evaluation_opponents)
        opponent_name = evaluation_opponent_names[i_opponent]
        stacked = stack(res[res[:Opponent].==opponent_name,:], [:WinPercentage, :DrawPercentage, :LossPercentage])
        rename!(stacked, [:variable, :value], [:Group, :Score])
        draw(PNG(@sprintf("plots/players_v%s.png", opponent_name), 8inch, 6inch), plot(stacked, x=:Name, y=:Score, color=:Group, Geom.boxplot))
        draw(PNG(@sprintf("plots/players_v%s_scatter.png", opponent_name), 8inch, 6inch), plot(res[res[:Opponent].==opponent_name,:], x=:WinPercentage, y=:DrawPercentage, color=:Name, Geom.point))
    end
end
