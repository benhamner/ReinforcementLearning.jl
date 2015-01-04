using MachineLearning
using ReinforcementLearning

function train_q_net_player_h(play_game_function,
                            num_features,
                            players::Vector{Function};
                            hidden_layers=[25],
                            num_history=50_000)
    opts = regression_net_options(hidden_layers=hidden_layers, regularization_factor=0.00)
    net  = initialize_regression_net(opts, num_features)
    temp = initialize_neural_net_temporary(net)

    history = zeros(num_history, num_features)
    other_player_response = zeros(Int, num_history)
    reward = zeros(num_history)
    moves = Array(Vector{Int}, num_history)

    q_net_player = make_q_net_player(net)
    possible_players = copy(players)
    push!(possible_players, q_net_player)
    alpha = 0.5
    i_history = 0
    while i_history<num_history
        player_1 = rand(possible_players)
        player_2 = rand(possible_players)
        states, win_state = play_game_function(player_1, player_2)
        
        for (i,s)=enumerate(states)
            i_history += 1
            if i_history > num_history
                continue
            end
            history[i_history,:]  = game_to_input_features(s[1], s[2], s[3])
            if i<=length(states)-2
                moves[i_history] = possible_moves(states[i+2][1])
                other_player_response[i_history] = states[i+1][3]
            else
                moves[i_history] = Int[]
                reward[i_history] = win_state==3 ? 0.5 : (win_state==s[2] ? 1 : 0)
            end 
        end
    end

    sample = zeros(num_features)

    for i=1:1_000_000
        loc = rand(1:num_history)
        sample[:] = history[loc,:]
        q_sample = predict(net, sample)
        sample[other_player_response[loc]+9] = 1

        max_q = 0.0
        for m=moves[loc]
            sample[m] = 1
            max_q = max(max_q, predict(net, sample))
            sample[m] = 0
        end
        target = sigmoid((1-alpha)*q_sample + alpha*(reward[loc]+max_q))
        MachineLearning.update_weights!(net, sample, [target], net.options.learning_rate, net.options.regularization_factor, 100, temp)
    end

    net, q_net_player
end

for sample=1:20
    q_net, q_net_player = train_q_net_player_h(play_tic_tac_toe_track_state,
                                               18,
                                               [random_player, perfect_player])
    win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 10_000)
    println("Q net vs random: ", results_txt)
end
