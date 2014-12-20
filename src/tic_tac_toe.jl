
type TicTacToe <: Game
    board::Vector{Int}
end

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

function play_tic_tac_toe_random_first_move(player_1::Function, player_2::Function)
    if rand(1:2)==1
        return play_tic_tac_toe(player_1, player_2)
    end
    res = play_tic_tac_toe(player_2, player_1)
    res < 3 ? 3-res : res
end
