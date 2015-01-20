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
base_players = Vector{Function}[[], [random_player], [random_player], [random_player, perfect_player], [perfect_player]]
base_player_names = ["Self", "Rand", "Rand+Self", "Rand+Perf+Self", "Perf+Self"]
play_self = [true, false, true, true, true]

train_functions = vcat([() -> train_q_net_player(play_tic_tac_toe_track_state,
                                                 18,
                                                 base_players[i],
                                                 num_games=num_games,
                                                 net_options=regression_net_options(hidden_layers=hidden_layers,
                                                                                    regularization_factor=0.0,
                                                                                    learning_rate=learning_rate),
                                                 self_play=play_self[i]) for i=1:length(base_players)],
                       [() -> train_q_learning_player(base_players[i],
                                                      num_games=num_games,
                                                      self_play=play_self[i]) for i=1:length(base_players)])
player_names = vcat(base_player_names, ["Q"*n for n=base_player_names])

evaluation_opponents = [random_player, perfect_player]
evaluation_opponent_names = ["rand", "perf"]

compare_players(train_functions,
                player_names,
                evaluation_opponents,
                evaluation_opponent_names,
                evaluate_tic_tac_toe_players,
                num_iterations=10,
                num_test_games=1_000,
                plot_dir="plots")
