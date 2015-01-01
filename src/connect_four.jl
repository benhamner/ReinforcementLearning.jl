
immutable ConnectFour <: Game
    board::Array{Int, 2}
end
Base.hash(game::ConnectFour, h::UInt) = hash(game.board, h)
Base.isequal(g1::ConnectFour, g2::ConnectFour) = isequal(g1.board, g2.board)
==(g1::ConnectFour, g2::ConnectFour) = g1.board==g2.board

initialize_connect_four() = ConnectFour(zeros(Int, 6, 7))

function win_state(game::ConnectFour)
    # 0 = no one wins
    # 1 = player 1 wins
    # 2 = player 2 wins
    # 3 = draw
    for row=1:6
        for col=1:7
            for player=1:2
                # vertical win
                if row<=3 && sum(game.board[row:row+3,col].==player)==4
                    return player
                end
                # horizontal win
                if col<=4 && sum(game.board[row,col:col+3].==player)==4
                    return player
                end
                # diagonal top-left to bottom-right win
                win_locs = [6*(col+i-1)+(row+i) for i=0:3]
                if row<=3 && col<=4 && sum(game.board[win_locs].==player)==4
                    return player
                end
                # diagonal top-right to bottom-left win
                win_locs = [6*(col+3-i-1)+(row+i) for i=0:3]
                if row<=3 && col<=4 && sum(game.board[win_locs].==player)==4
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

possible_moves(game::ConnectFour) = filter(col -> game.board[1,col]==0, Int[1:7])
random_player(game::ConnectFour, player::Int) = rand(possible_moves(game))

function move!(game::ConnectFour, player::Int, move::Int)
    row = maximum(find(game.board[:,move].==0))
    if game.board[row,move]==0
        game.board[row,move] = player
    else
        throw("Error: Invalid Move: " * move * " on board: " * string(game.board))
    end
    game
end

function play_connect_four(player_1::Function, player_2::Function)
    game = initialize_connect_four()
    turn = 1
    while win_state(game)==0
        col = turn==1 ? player_1(game, turn) : player_2(game, turn)
        move!(game, turn, col)
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

function lookahead(game::ConnectFour, player::Int, moves_left::Int)
    state = win_state(game)
    if state>0
        return (state, Int[])
    end
    moves = possible_moves(game)
    if moves_left==0
        return (0, moves)
    end
    states = Int[]
    for move=moves
        new_game = ConnectFour(copy(game.board))
        move!(new_game, player, move)
        push!(states, lookahead(new_game, 3-player, moves_left-1)[1])
    end
    if in(player, states)
        return (player, moves[states.==player])
    elseif in(3, states)
        return (3, moves[states.==3])
    elseif in(0, states)
        return (0, moves[states.==0])
    else
        return (states[1], moves)
    end
end

function make_lookahead_player(num_moves::Int)
    function lookahead_player(game::ConnectFour, player::Int)
        outcome, best_moves = lookahead(game, player, num_moves)
        rand(best_moves)
    end
end

