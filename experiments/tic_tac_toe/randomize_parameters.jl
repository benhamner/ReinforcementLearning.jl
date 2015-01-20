using Gadfly
using MachineLearning
using ReinforcementLearning

num_trials = 100_000

hidden_layers  = Vector{Int}[[5], [10], [25], [50], [100], [200], [10,10], [25,25], [25,10], [50,50], [100,10]]
learning_rates = vcat([[1,2,5].*10.0^x for x=-5:5]...)
num_games      = [1_000, 2_000, 5_000, 10_000, 20_000, 50_000]
alphas         = [0.05:0.05:1.0]
num_test_games = 2_000

base_players = Vector{Function}[[], [random_player], [random_player], [random_player, perfect_player], [perfect_player]]
base_player_names = ["Self", "Rand", "Rand+Self", "Rand+Perf+Self", "Perf+Self"]
play_self = [true, false, true, true, true]

evaluation_opponents = [random_player, perfect_player]
evaluation_opponent_names = ["rand", "perf"]

res = DataFrame(Opponent=[],
                HiddenLayer=[],
                LearningRates=[],
                NumGames=[],
                Alpha=[],
                Trial=[],
                WinPercentage=[],
                DrawPercentage=[],
                LossPercentage=[])

for i_trial=1:num_trials
    println("Trial ", i_trial)
    layers        = rand(hidden_layers)
    learning_rate = rand(learning_rates)
    games         = rand(num_games)
    alpha         = rand(alphas)
    println("--Layers: ", layers, ", LRate: ", learning_rate, "\n--Games: ", games, ", Alpha: ", alpha)

    q, q_player = train_q_net_player(play_tic_tac_toe_track_state,
                                     18,
                                     [random_player],
                                     num_games=games,
                                     net_options=regression_net_options(hidden_layers=layers,
                                                                        regularization_factor=0.0,
                                                                        learning_rate=learning_rate),
                                     self_play=true,
                                     alpha = alpha)
    for i_opponent = 1:length(evaluation_opponents)
        win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_player, evaluation_opponents[i_opponent], num_test_games)
        opponent_name = evaluation_opponent_names[i_opponent]
        res = vcat(res, DataFrame(Opponent=[opponent_name],
                                  HiddenLayer=Vector{Int}[layers],
                                  LearningRates=[learning_rate],
                                  NumGames=[games],
                                  Alpha=[alpha],
                                  Trial=[i_trial],
                                  WinPercentage=[win_percentage],
                                  DrawPercentage=[draw_percentage],
                                  LossPercentage=[loss_percentage]))
    end
    writetable("plots/randomize_parameters.csv", res)
end

println(res)