using ReinforcementLearning

lookahead_player=make_lookahead_player(1)

while true
    result = play_connect_four_random_first_move(command_player, lookahead_player)
    if result==1
        println("Congratulations, you won!")
    elseif result==2
        println("You lost :(")
    else
        println("Draw :/")
    end
    println()
end