abstract Game

int_to_string(x::Int) = x==0 ? " " : (x==1 ? "X" : "O")
random_player(game::Game, player::Int) = rand(possible_moves(game))

function play_game(game_type::Type, player_1::Function, player_2::Function)
    game = game_type()
    turn = 1
    while win_state(game)==0
        move = turn==1 ? player_1(game, turn) : player_2(game, turn)
        move!(game, turn, move)
        turn = 3 - turn # alternates between 1 and 2
    end
    win_state(game)
end

function play_game_random_first_move(game_type::Type, player_1::Function, player_2::Function)
    if rand(1:2)==1
        return play_game(game_type, player_1, player_2)
    end
    res = play_game(game_type, player_2, player_1)
    res < 3 ? 3-res : res
end

function play_game_track_state(game_type::Type, player_1::Function, player_2::Function)
    game = game_type()
    states = Array((game_type, Int, Int), 0) # state, turn, move
    turn = 1
    while win_state(game)==0
        col = turn==1 ? player_1(game, turn) : player_2(game, turn)
        push!(states, (copy(game), turn, col))
        move!(game, turn, col)
        turn = 3 - turn # alternates between 1 and 2
    end
    states, win_state(game)
end

function make_q_net_player(net::RegressionNet)
    function q_net_player(game, player::Int)
        max_score = -Inf
        moves = possible_moves(game)
        best_move = moves[1]
        for move=moves
            score = predict(net, game_to_input_features(game, player, move))
            if score>max_score
                max_score = score
                best_move = move
            end
        end
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
                            net_options=regression_net_options(regularization_factor=0.0),
                            self_play::Bool=true,
                            alpha::Float64=0.5)
    if !self_play && length(players)==0
        throw("Need to have at least one game player")
    end
    net = initialize_regression_net(net_options, num_features)
    temp = initialize_neural_net_temporary(net)

    q_net_player = make_q_net_player(net)
    possible_players = copy(players)
    if self_play
        push!(possible_players, q_net_player)
    end

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

function compare_players(train_functions::Vector{Function},
                         train_function_names,
                         evaluation_opponents::Vector{Function},
                         evaluation_opponent_names,
                         evaluate_players::Function;
                         num_iterations::Int=10,
                         num_test_games::Int=1_000,
                         plot_dir::ASCIIString="")
    res = DataFrame(Name=[], Opponent=[], Iteration=[], WinPercentage=[], DrawPercentage=[], LossPercentage=[])
    for iteration=1:num_iterations
        println("Iteration: ", iteration)
        for i_train_function=1:length(train_functions)
            q, q_player = train_functions[i_train_function]()
            for i_opponent = 1:length(evaluation_opponents)
                win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_players(q_player, evaluation_opponents[i_opponent], num_test_games)
                opponent_name = evaluation_opponent_names[i_opponent]
                res = vcat(res, DataFrame(Name=train_function_names[i_train_function], Opponent=opponent_name, Iteration=iteration, WinPercentage=win_percentage, DrawPercentage=draw_percentage, LossPercentage=loss_percentage))
                println("qnet v ", opponent_name, ": ", results_txt)
            end
        end
        for i_opponent = 1:length(evaluation_opponents)
            opponent_name = evaluation_opponent_names[i_opponent]
            stacked = DataFrames.stack(res[res[:Opponent].==opponent_name,:], [:WinPercentage, :DrawPercentage, :LossPercentage])
            rename!(stacked, [:variable, :value], [:Group, :Score])
            draw(PNG(joinpath(plot_dir, @sprintf("players_v%s.png", opponent_name)), 8inch, 6inch), plot(stacked, x=:Name, y=:Score, color=:Group, Geom.boxplot))
            draw(PNG(joinpath(plot_dir, @sprintf("players_v%s_scatter.png", opponent_name)), 8inch, 6inch), plot(res[res[:Opponent].==opponent_name,:], x=:WinPercentage, y=:DrawPercentage, color=:Name, Geom.point))
        end
    end
end
