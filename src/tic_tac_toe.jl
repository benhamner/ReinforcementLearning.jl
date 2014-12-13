
type TicTacToe <: Game
    board::Vector{Int}
end

initialize_tic_tac_toe = () -> TicTacToe(zeros(Int, 9))

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