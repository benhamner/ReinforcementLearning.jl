using Gadfly
using MachineLearning
using ReinforcementLearning

hidden_layers = [25]
learning_rate = 500.0
num_games     = 10_000

println("Hidden Layers: ", hidden_layers)
println("Learning Rate: ", learning_rate)
println("Num Games:     ", num_games)

vrand  = DataFrame(Name=[], Iteration=[], Score=[], Group=[])
vrand2 = DataFrame(Name=[], Iteration=[], WinPercentage=[], DrawPercentage=[], LossPercentage=[])
vperf  = DataFrame(Name=[], Iteration=[], Score=[], Group=[])
vperf2 = DataFrame(Name=[], Iteration=[], WinPercentage=[], DrawPercentage=[], LossPercentage=[])
iterations=50
players = Vector{Function}[[random_player], [random_player, perfect_player], [perfect_player]]
player_names = ["Rand", "Rand+Perf", "Perf"]
for i=1:iterations
    for j=1:length(players)
        q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                               18,
                                               players[j],
                                               num_games=num_games,
                                               net_options=regression_net_options(hidden_layers=hidden_layers,
                                                                                  regularization_factor=0.0,
                                                                                  learning_rate=learning_rate))
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 2_000)
        println("qnet v rand: ", results_txt)
        vrand  = vcat(vrand,  DataFrame(Name=player_names[j], Iteration=i, Score=win_percentage,  Group="Win"))
        vrand  = vcat(vrand,  DataFrame(Name=player_names[j], Iteration=i, Score=draw_percentage, Group="Draw"))
        vrand  = vcat(vrand,  DataFrame(Name=player_names[j], Iteration=i, Score=loss_percentage, Group="Loss"))
        vrand2 = vcat(vrand2, DataFrame(Name=player_names[j], Iteration=i, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, perfect_player, 2_000)
        println("qnet v perf: ", results_txt)
        vperf  = vcat(vperf,  DataFrame(Name=player_names[j], Iteration=i, Score=win_percentage,  Group="Win"))
        vperf  = vcat(vperf,  DataFrame(Name=player_names[j], Iteration=i, Score=draw_percentage, Group="Draw"))
        vperf  = vcat(vperf,  DataFrame(Name=player_names[j], Iteration=i, Score=loss_percentage, Group="Loss"))
        vperf2 = vcat(vperf2, DataFrame(Name=player_names[j], Iteration=i, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
    end
    draw(PNG("plots/players_vrand.png", 8inch, 6inch), plot(vrand, x=:Name, y=:Score, color=:Group, Geom.boxplot))
    draw(PNG("plots/players_vrand_scatter.png", 8inch, 6inch), plot(vrand2, x=:WinPercentage, y=:DrawPercentage, color=:Name, Geom.point))
    draw(PNG("plots/players_vperf.png", 8inch, 6inch), plot(vperf, x=:Name, y=:Score, color=:Group, Geom.boxplot))
    draw(PNG("plots/players_vperf_scatter.png", 8inch, 6inch), plot(vperf2, x=:DrawPercentage, y=:LossPercentage, color=:Name, Geom.point))
end
