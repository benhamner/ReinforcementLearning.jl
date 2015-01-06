abstract Game

int_to_string(x::Int) = x==0 ? " " : (x==1 ? "X" : "O")
random_player(game::Game, player::Int) = rand(possible_moves(game))

function make_q_net_player(net::RegressionNet)
    function q_net_player(game, player::Int)
        max_score = -Inf
        best_move = -1
        for move=possible_moves(game)
            score = predict(net, game_to_input_features(game, player, move))
            #println("Score ", score)
            if score>max_score
                max_score = score
                best_move = move
            end
        end
        #println("Best move ", best_move)
        return best_move
    end
end

function learn_from_states_net!(net, temp, alpha, states, win_state, player)
    reward = win_state==3 ? 0.5 : (win_state==player ? 1 : 0)
    for i=1:length(states)-1
        max_q  = maximum([predict(net, game_to_input_features(states[i+1][1], states[i][2], m)) for m=possible_moves(states[i+1][1])])
        sample = game_to_input_features(states[i][1], states[i][2], states[i][3])
        target = sigmoid((1-alpha)*predict(net, sample) + alpha*max_q)
        MachineLearning.update_weights!(net, sample, [target], net.options.learning_rate, net.options.regularization_factor, 100, temp)
    end
    sample = game_to_input_features(states[end][1], states[end][2], states[end][3])
    target = sigmoid((1-alpha)*predict(net, sample) + alpha*reward)
    MachineLearning.update_weights!(net, sample, [target], net.options.learning_rate, net.options.regularization_factor, 100, temp)
end

function train_q_net_player(play_game_function,
                            num_features,
                            players::Vector{Function};
                            num_games=10_000,
                            net_options=regression_net_options(regularization_factor=0.0))
    net = initialize_regression_net(net_options, num_features)
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
        learn_from_states_net!(net, temp, alpha, states[1:2:end], win_state, 1)

        # Learn from player 2
        learn_from_states_net!(net, temp, alpha, states[2:2:end], win_state, 2)
    end
    net, q_net_player
end

function evaluate_players(game_function::Function, player_1::Function, player_2::Function, num_samples::Int)
    wins  = 0
    draws = 0
    for i=1:num_samples
       winner = game_function(player_1, player_2)
       wins  += winner==1 ? 1 : 0
       draws += winner==3 ? 1 : 0
    end
    win_percentage = wins / num_samples * 100
    draw_percentage = draws / num_samples * 100
    loss_percentage = (num_samples-wins-draws) / num_samples * 100
    results_text = @sprintf("%2.2f%% wins, %2.2f%% losses, %2.2f%% draws, %2.2f%% relative wins", win_percentage, loss_percentage, draw_percentage, wins/(num_samples-draws)*100.0)
    win_percentage, draw_percentage, loss_percentage, results_text
end

