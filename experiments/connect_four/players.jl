using Gadfly
using MachineLearning
using ReinforcementLearning

hidden_layers = [25]
learning_rate = 500.0
num_games     = 50_000

println("Hidden Layers: ", hidden_layers)
println("Learning Rate: ", learning_rate)
println("Num Games:     ", num_games)

iterations=50
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

compare_players(train_functions,
                player_names,
                evaluation_opponents,
                evaluation_opponent_names,
                evaluate_connect_four_players,
                num_iterations=10,
                num_test_games=1_000,
                plot_dir="plots")