
immutable ConnectFour <: Game
    board::Array{Int, 2}
end
Base.hash(game::ConnectFour, h::UInt) = hash(game.board, h)
Base.isequal(g1::ConnectFour, g2::ConnectFour) = isequal(g1.board, g2.board)
==(g1::ConnectFour, g2::ConnectFour) = g1.board==g2.board

initialize_connect_four() = ConnectFour(zeros(Int, 6, 6))

function win_state(game::ConnectFour)
    # 0 = no one wins
    # 1 = player 1 wins
    # 2 = player 2 wins
    # 3 = draw
    for row=1:6
        for col=1:6
            for player=1:2
                # vertical win
                if row<=3 && sum(game.board[row:row+3,col].==player)==4
                    return player
                end
                # horizontal win
                if col<=3 && sum(game.board[row,col:col+3].==player)==4
                    return player
                end
                # diagonal top-left to bottom-right win
                win_locs = [6*(col+i-1)+(row+i) for i=0:3]
                if row<=3 && col<=3 && sum(game.board[win_locs].==player)==4
                    return player
                end
                # diagonal top-right to bottom-left win
                win_locs = [6*(col+3-i-1)+(row+i) for i=0:3]
                if row<=3 && col<=3 && sum(game.board[win_locs].==player)==4
                    return player
                end
            end
        end
    end
    if sum(game.board.==0)==0
        return 3
    end
    return 0
end

possible_moves(game::ConnectFour) = filter(col -> game.board[1,col]==0, Int[1:6])