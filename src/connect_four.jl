
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
random_player(game::ConnectFour, player::Int) = rand(possible_moves(game))

function play_connect_four(player_1::Function, player_2::Function)
    game = initialize_connect_four()
    turn = 1
    while win_state(game)==0
        col = turn==1 ? player_1(game, turn) : player_2(game, turn)
        row = maximum(find(game.board[:,col].==0))
        if game.board[row,col]==0
            game.board[row,col] = turn
        else
            throw("Error: Invalid Move: " * col * " on board: " * string(game.board))
        end
        turn = 3 - turn # alternates between 1 and 2
    end
    win_state(game)
end

function play_connect_four_random_first_move(player_1::Function, player_2::Function)
    if rand(1:2)==1
        return play_connect_four(player_1, player_2)
    end
    res = play_connect_four(player_2, player_1)
    res < 3 ? 3-res : res
end

function evaluate_connect_four_players(player_1::Function, player_2::Function, num_samples::Int)
    wins  = 0
    draws = 0
    for i=1:num_samples
       winner = play_connect_four_random_first_move(player_1, player_2)
       wins  += winner==1 ? 1 : 0
       draws += winner==3 ? 1 : 0
    end
    win_percentage = wins / num_samples * 100
    draw_percentage = draws / num_samples * 100
    loss_percentage = (num_samples-wins-draws) / num_samples * 100
    results_text = @sprintf("%2.2f%% wins, %2.2f%% losses, %2.2f%% draws", win_percentage, loss_percentage, draw_percentage)
    win_percentage, draw_percentage, loss_percentage, results_text
end
