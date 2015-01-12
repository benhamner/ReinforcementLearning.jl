using Gadfly
using MachineLearning
using ReinforcementLearning

hidden_layers = [25]
learning_rate = 500.0
num_games     = 10_000

println("Hidden Layers: ", hidden_layers)
println("Learning Rate: ", learning_rate)
println("Num Games:     ", num_games)

res = DataFrame(Name=[], Opponent=[], Iteration=[], WinPercentage=[], DrawPercentage=[], LossPercentage=[])
iterations=50
players = Vector{Function}[[], [random_player], [random_player], [random_player, perfect_player], [perfect_player]]
player_names = ["Self", "Rand", "Rand+Self", "Rand+Perf+Self", "Perf+Self"]
play_self = [true, false, true, true, true]
for i=1:iterations
    for j=1:length(players)
        q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                               18,
                                               players[j],
                                               num_games=num_games,
                                               net_options=regression_net_options(hidden_layers=hidden_layers,
                                                                                  regularization_factor=0.0,
                                                                                  learning_rate=learning_rate),
                                               self_play=play_self[j])
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 2_000)
        res = vcat(res, DataFrame(Name=player_names[j], Opponent="Rand", Iteration=i, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
        println("qnet v rand: ", results_txt)
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, perfect_player, 2_000)
        res = vcat(res, DataFrame(Name=player_names[j], Opponent="Perf", Iteration=i, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
        println("qnet v perf: ", results_txt)
    end
    stacked_rand = stack(res[res[:Opponent].=="Rand",:], [:WinPercentage, :DrawPercentage, :LossPercentage])
    rename!(stacked_rand, [:variable, :value], [:Group, :Score])
    stacked_perf = stack(res[res[:Opponent].=="Perf",:], [:WinPercentage, :DrawPercentage, :LossPercentage])
    rename!(stacked_perf, [:variable, :value], [:Group, :Score])
    draw(PNG("plots/players_vrand.png", 8inch, 6inch), plot(stacked_rand, x=:Name, y=:Score, color=:Group, Geom.boxplot))
    draw(PNG("plots/players_vrand_scatter.png", 8inch, 6inch), plot(res[res[:Opponent].=="Rand",:], x=:WinPercentage, y=:DrawPercentage, color=:Name, Geom.point))
    draw(PNG("plots/players_vperf.png", 8inch, 6inch), plot(stacked_perf, x=:Name, y=:Score, color=:Group, Geom.boxplot))
    draw(PNG("plots/players_vperf_scatter.png", 8inch, 6inch), plot(res[res[:Opponent].=="Perf",:], x=:DrawPercentage, y=:LossPercentage, color=:Name, Geom.point))
end
