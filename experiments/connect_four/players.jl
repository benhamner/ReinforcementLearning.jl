using Gadfly
using MachineLearning
using ReinforcementLearning

hidden_layers = [25]
learning_rate = 500.0
num_games     = 50_000

println("Hidden Layers: ", hidden_layers)
println("Learning Rate: ", learning_rate)
println("Num Games:     ", num_games)

res = DataFrame(Name=[], Opponent=[], Iteration=[], WinPercentage=[], DrawPercentage=[], LossPercentage=[])
iterations=10
base_players = Vector{Function}[[], [random_player], [random_player], [random_player, make_lookahead_player(1)]]
base_player_names = ["Self", "Rand", "Rand+Self", "Rand+Self+LH1"]
play_self = [true, false, true, true]

train_functions = [() -> train_q_net_player(play_connect_four_track_state,
                                            84,
                                            base_players[i],
                                            num_games=num_games,
                                            net_options=regression_net_options(hidden_layers=hidden_layers,
                                                                               regularization_factor=0.0,
                                                                               learning_rate=learning_rate),
                                            self_play=play_self[i]) for i=1:length(base_players)]
player_names = base_player_names

for i=1:iterations
    println("Iteration: ", i)
    for j=1:length(train_functions)
        q, q_player = train_functions[j]()
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_player, random_player, 1_000)
        res = vcat(res, DataFrame(Name=player_names[j], Opponent="Rand", Iteration=i, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
        println("qnet v rand: ", results_txt)
        @time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_player, make_lookahead_player(1), 1_000)
        res = vcat(res, DataFrame(Name=player_names[j], Opponent="LH1", Iteration=i, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
        println("qnet v lh1:  ", results_txt)
        @time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(q_player, make_lookahead_player(2), 1_000)
        res = vcat(res, DataFrame(Name=player_names[j], Opponent="LH2", Iteration=i, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
        println("qnet v lh2:  ", results_txt)
    end
    stacked_rand = stack(res[res[:Opponent].=="Rand",:], [:WinPercentage, :DrawPercentage, :LossPercentage])
    rename!(stacked_rand, [:variable, :value], [:Group, :Score])
    stacked_lh1  = stack(res[res[:Opponent].=="LH1",:], [:WinPercentage, :DrawPercentage, :LossPercentage])
    rename!(stacked_lh1, [:variable, :value], [:Group, :Score])
    stacked_lh2  = stack(res[res[:Opponent].=="LH2",:], [:WinPercentage, :DrawPercentage, :LossPercentage])
    rename!(stacked_lh2, [:variable, :value], [:Group, :Score])
    draw(PNG("plots/players_vrand.png", 8inch, 6inch), plot(stacked_rand, x=:Name, y=:Score, color=:Group, Geom.boxplot))
    draw(PNG("plots/players_vrand_scatter.png", 8inch, 6inch), plot(res[res[:Opponent].=="Rand",:], x=:WinPercentage, y=:DrawPercentage, color=:Name, Geom.point))
    draw(PNG("plots/players_vlh1.png", 8inch, 6inch), plot(stacked_lh1, x=:Name, y=:Score, color=:Group, Geom.boxplot))
    draw(PNG("plots/players_vlh1_scatter.png", 8inch, 6inch), plot(res[res[:Opponent].=="LH1",:], x=:DrawPercentage, y=:LossPercentage, color=:Name, Geom.point))
    draw(PNG("plots/players_vlh2.png", 8inch, 6inch), plot(stacked_lh2, x=:Name, y=:Score, color=:Group, Geom.boxplot))
    draw(PNG("plots/players_vlh2_scatter.png", 8inch, 6inch), plot(res[res[:Opponent].=="LH2",:], x=:DrawPercentage, y=:LossPercentage, color=:Name, Geom.point))
end
