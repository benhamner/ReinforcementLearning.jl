using ReinforcementLearning

q_table, q_player = train_q_learning_player()

while true
    result = play_tic_tac_toe_random_first_move(command_player, q_player)
    if result==1
        println("Congratulations, you won!")
    elseif result==2
        println("You lost :(")
    else
        println("Draw :/")
    end
    println()
end