
immutable TicTacToe <: Game
    board::Vector{Int}
end
Base.hash(game::TicTacToe, h::UInt) = hash(game.board, h)
Base.isequal(g1::TicTacToe, g2::TicTacToe) = isequal(g1.board, g2.board)
==(g1::TicTacToe, g2::TicTacToe) = g1.board==g2.board

initialize_tic_tac_toe() = TicTacToe(zeros(Int, 9))

function win_state(game::TicTacToe)
    # 0 = no one wins
    # 1 = player 1 wins
    # 2 = player 2 wins
    # 3 = draw
    col_locs     = [[i:i+2] for i=1:3:9]
    row_locs     = [[i:3:9] for i=1:3]
    diag_locs    = Array(Vector{Int}, 2)
    diag_locs[1] = [1,5,9]
    diag_locs[2] = [3,5,7]
    for win_locs=vcat(col_locs, row_locs, diag_locs)
        for player=1:2
            if sum(game.board[win_locs].==player)==3
                return player
            end
        end
    end
    if sum(game.board.==0)==0
        return 3
    end
    return 0
end

possible_moves(game::TicTacToe) = find(game.board.==0)
center_player(game::TicTacToe, player::Int) = game.board[5]==0 ? 5 : random_player(game, player)

function play_tic_tac_toe(player_1::Function, player_2::Function)
    game = initialize_tic_tac_toe()
    turn = 1
    while win_state(game)==0
        move = turn==1 ? player_1(game, turn) : player_2(game, turn)
        if game.board[move]==0
            game.board[move] = turn
        else
            throw("Error: Invalid Move: " * string(move) * " on board: " * string(game.board))
        end
        turn = 3 - turn # alternates between 1 and 2
    end
    win_state(game)
end

function play_tic_tac_toe_track_state(player_1::Function, player_2::Function)
    game = initialize_tic_tac_toe()
    states = Array((TicTacToe, Int, Int), 0) # state, turn, move
    turn = 1
    while win_state(game)==0
        move = turn==1 ? player_1(game, turn) : player_2(game, turn)
        push!(states, (TicTacToe(copy(game.board)), turn, move))
        if game.board[move]==0
            game.board[move] = turn
        else
            throw("Error: Invalid Move: " * string(move) * " on board: " * string(game.board))
        end
        turn = 3 - turn # alternates between 1 and 2
    end
    states, win_state(game)
end

function play_tic_tac_toe_random_first_move(player_1::Function, player_2::Function)
    if rand(1:2)==1
        return play_tic_tac_toe(player_1, player_2)
    end
    res = play_tic_tac_toe(player_2, player_1)
    res < 3 ? 3-res : res
end

function evaluate_tic_tac_toe_players(player_1::Function, player_2::Function, num_samples::Int)
    wins  = 0
    draws = 0
    for i=1:num_samples
       winner = play_tic_tac_toe_random_first_move(player_1, player_2)
       wins  += winner==1 ? 1 : 0
       draws += winner==3 ? 1 : 0
    end
    win_percentage = wins / num_samples * 100
    draw_percentage = draws / num_samples * 100
    loss_percentage = (num_samples-wins-draws) / num_samples * 100
    results_text = @sprintf("%2.2f%% wins, %2.2f%% losses, %2.2f%% draws, %2.2f%% comparitive wins", win_percentage, loss_percentage, draw_percentage, wins/(num_samples-draws)*100.0)
    win_percentage, draw_percentage, loss_percentage, results_text
end

board_positions = Dict{(TicTacToe, Int), (Int, Vector{Int})}()
function evaluate_board(game::TicTacToe, player::Int)
    if haskey(board_positions, (game, player))
        return board_positions[(game, player)]
    end
    this_win_state = win_state(game)
    if this_win_state>0
        board_positions[(game, player)] = (this_win_state, Int[])
        return board_positions[(game, player)]
    end
    states = Int[]
    moves  = possible_moves(game)
    for m=moves
        new_game = TicTacToe(copy(game.board))
        new_game.board[m] = player
        board_state = evaluate_board(new_game, 3-player)[1]
        push!(states, board_state)
    end
    if in(player, states)
        best_moves = moves[states.==player]
        board_positions[(game, player)] = (player, best_moves)
    elseif in(3, states)
        best_moves = moves[states.==3]
        board_positions[(game, player)] = (3, best_moves)
    else
        best_moves = moves[states.==3-player]
        board_positions[(game, player)] = (3-player, best_moves)
    end
    return board_positions[(game, player)]
end

function perfect_player(game::TicTacToe, player::Int)
    outcome, best_moves = evaluate_board(game, player)
    rand(best_moves)
end

function make_q_player(q_table::DefaultDict{(TicTacToe,Int,Int), Float64})
    function q_player(game::TicTacToe, player::Int)
        max_score = -Inf
        best_move = -1
        for move=possible_moves(game)
            if haskey(q_table, (game, player, move))
                if q_table[(game, player, move)]>max_score
                    max_score = q_table[(game, player, move)]
                    best_move = move
                end
            end
        end
        if best_move > -1
            return best_move
        end
        return random_player(game, player)
    end
end

function make_exploration_player(this_player, rate = 0.5)
    function exploration_player(game::TicTacToe, player::Int)
        rand()<rate ? random_player(game, player) : this_player(game, player)
    end
end

function learn_from_states!(q_table::DefaultDict{(TicTacToe,Int,Int), Float64}, alpha, states, win_state, player)
    reward = win_state==3 ? 0.5 : (win_state==player ? 1 : 0)
    for i=1:length(states)-1
        max_q = maximum([q_table[(states[i+1][1],states[i][2], m)] for m=possible_moves(states[i+1][1])])
        q_table[states[i]] = (1-alpha)*q_table[states[i]] + alpha*max_q
    end
    q_table[states[end]] = (1-alpha)*q_table[states[end]]+alpha*reward
end

function train_q_learning_player()
    q_table = DefaultDict((TicTacToe,Int,Int), Float64, 0.0)
    q_player = make_q_player(q_table)
    alpha = 0.1
    num_games = 10_000
    for i=1:num_games
        player_1 = rand([q_player, random_player, perfect_player])
        player_2 = rand([q_player, random_player, perfect_player])
        states, win_state = play_tic_tac_toe_track_state(player_1, player_2)
        
        # Learn from player 1
        learn_from_states!(q_table, alpha, states[1:2:end], win_state, 1)

        # Learn from player 2
        learn_from_states!(q_table, alpha, states[2:2:end], win_state, 2)
    end
    q_table, q_player
end

function game_to_input_features(game::TicTacToe, player::Int, move::Int)
    fea = zeros(18)
    fea[find(game.board.==player)] = 1
    fea[find(game.board.==3-player)+9] = 1
    fea[move] = 1
    #fea[19] = player==1 ? 1:0
    #fea[(player==1 ? 0 : 9) + move] = 1
    fea
end

board_to_string(game::TicTacToe) = join([join([int_to_string(x) for x=game.board[i:i+2]], "|") for i=1:3:9], "\n-----\n")

function command_player(game::TicTacToe, player::Int)
    println(board_to_string(game))
    println("You are player ", int_to_string(player))
    input = readline(STDIN)
    int(input)
end

function plot_tic_tac_toe_neuron(weights::Vector{Float64})
    @assert length(weights)==18
    player = vcat(["F" for i=1:9], ["E" for i=1:9])
    rows   = [1,1,1,2,2,2,3,3,3,1,1,1,2,2,2,3,3,3]
    cols   = vcat([[1:3] for x=1:6]...)
    data   = DataFrame(Player=player, Rows=rows, Cols=cols, Weights=weights)
    layer(data,
          x=:Player,
          y=:Weights,
          color=:Player,
          xgroup=:Cols,
          ygroup=:Rows,
          Geom.subplot_grid(Geom.bar))
end

function plot_tic_tac_toe_neurons(net::NeuralNet)

end