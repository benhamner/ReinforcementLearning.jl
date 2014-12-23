
type TicTacToe <: Game
    board::Vector{Int}
end
#Base.hash(game::TicTacToe) = hash(game.board)

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
random_player(game::TicTacToe, player::Int) = rand(possible_moves(game))
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
    states = Array((Vector{Int}, Int, Int), 0) # state, turn, move
    turn = 1
    while win_state(game)==0
        move = turn==1 ? player_1(game, turn) : player_2(game, turn)
        push!(states, (copy(game.board), turn, move))
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
    loss_percentage = 100 - win_percentage - draw_percentage
    win_percentage, draw_percentage, loss_percentage
end

function make_q_player(q_table::Dict{(Vector{Int64},Int,Int), Float64})
    function q_player(game::TicTacToe, player::Int)
        max_score = -Inf
        best_move = -1
        for move=possible_moves(game)
            if haskey(q_table, (game.board, player, move))
                if q_table[(game.board, player, move)]>max_score
                    max_score = q_table[(game.board, player, move)]
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

function train_q_learning_player()
    q_table = Dict{(Vector{Int},Int,Int), Float64}()
    alpha = 0.1
    num_games = 30_000
    for i=1:num_games
        states, win_state = play_tic_tac_toe_track_state(random_player, random_player)
        for state = states
            reward = win_state==3 ? 0 : (win_state==state[2] ? 1 : -1)
            if !haskey(q_table, state)
                q_table[state] = 0.0
            end
            q_table[state] = (1-alpha)*q_table[state] + alpha*reward
        end
    end
    q_table, make_q_player(q_table)
end
