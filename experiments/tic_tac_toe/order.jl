using MachineLearning
using ReinforcementLearning

function learn_from_states_net_r!(net, temp, alpha, states, win_state, player)
    reward = win_state==3 ? 0.5 : (win_state==player ? 1 : 0)
    sample = game_to_input_features(states[end][1], states[end][2], states[end][3])
    target = sigmoid((1-alpha)*predict(net, sample) + alpha*reward)
    MachineLearning.update_weights!(net, sample, [target], net.options.learning_rate, net.options.regularization_factor, 100, temp)
    for i=length(states)-1:-1:1
        max_q  = maximum([predict(net, game_to_input_features(states[i+1][1], states[i][2], m)) for m=possible_moves(states[i+1][1])])
        sample = game_to_input_features(states[i][1], states[i][2], states[i][3])
        target = sigmoid((1-alpha)*predict(net, sample) + alpha*max_q)
        MachineLearning.update_weights!(net, sample, [target], net.options.learning_rate, net.options.regularization_factor, 100, temp)
    end
end

function train_q_net_player_r(play_game_function,
                            num_features,
                            players::Vector{Function};
                            hidden_layers=[100],
                            num_games=10_000)
    opts = regression_net_options(hidden_layers=hidden_layers, regularization_factor=0.0)
    net = initialize_regression_net(opts, num_features)
    temp = initialize_neural_net_temporary(net)

    q_net_player = make_q_net_player(net)
    possible_players = copy(players)
    push!(possible_players, q_net_player)
    alpha = 0.5
    for i=1:num_games
        player_1 = rand(possible_players)
        player_2 = rand(possible_players)
        states, win_state = play_game_function(player_1, player_2)
        
        # Learn from player 1
        learn_from_states_net_r!(net, temp, alpha, states[1:2:end], win_state, 1)

        # Learn from player 2
        learn_from_states_net_r!(net, temp, alpha, states[2:2:end], win_state, 2)
    end
    net, q_net_player
end

println("Reversed: ")
for sample=1:5
    q_net, q_net_player = train_q_net_player_r(play_tic_tac_toe_track_state,
                                               18,
                                               [random_player, perfect_player])
    win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 10_000)
    println("Q net vs random: ", results_txt)
end

println("Normal: ")
for sample=1:5
    q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state,
                                             18,
                                             [random_player, perfect_player])
    win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 10_000)
    println("Q net vs random: ", results_txt)
end