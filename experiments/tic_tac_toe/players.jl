using Gadfly
using MachineLearning
using ReinforcementLearning

hidden_layers = [25]
learning_rate = 500.0
num_games     = 10_000

println("Hidden Layers: ", hidden_layers)
println("Learning Rate: ", learning_rate)
println("Num Games:     ", num_games)

res  = DataFrame(Name=[], Iteration=[], Score=[], Group=[])
res2 = DataFrame(Name=[], Iteration=[], WinPercentage=[], DrawPercentage=[], LossPercentage=[])
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
        res  = vcat(res,  DataFrame(Name=player_names[j], Iteration=i, Score=win_percentage,  Group="Win"))
        res  = vcat(res,  DataFrame(Name=player_names[j], Iteration=i, Score=draw_percentage, Group="Draw"))
        res  = vcat(res,  DataFrame(Name=player_names[j], Iteration=i, Score=loss_percentage, Group="Loss"))
        res2 = vcat(res2, DataFrame(Name=player_names[j], Iteration=i, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
    end
    draw(PNG("plots/players.png", 8inch, 6inch), plot(res, x=:Name, y=:Score, color=:Group, Geom.boxplot))
    draw(PNG("plots/players_scatter.png", 8inch, 6inch), plot(res2, x=:WinPercentage, y=:DrawPercentage, color=:Name, Geom.point))
end
