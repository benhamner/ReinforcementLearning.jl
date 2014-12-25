using Base.Test
using ReinforcementLearning

@test win_state(TicTacToe([0,0,0,
                           0,0,0,
                           0,0,0])) == 0

@test win_state(TicTacToe([1,0,0,
                           0,1,0,
                           0,0,2])) == 0

@test win_state(TicTacToe([1,2,0,
                           2,1,0,
                           0,0,1])) == 1

@test win_state(TicTacToe([2,2,2,
                           0,1,0,
                           1,0,1])) == 2

@test win_state(TicTacToe([0,1,2,
                           0,1,2,
                           1,0,2])) == 2

@test win_state(TicTacToe([1,2,2,
                           2,1,1,
                           1,1,2])) == 3

@test win_state(TicTacToe([1,2,1,
                           1,1,2,
                           2,1,2])) == 3



win_percentage, draw_percentage, loss_percentage = evaluate_tic_tac_toe_players(random_player, random_player, 10_000)
@test draw_percentage < 20.0
@test draw_percentage > 5.0
@test win_percentage*100/(win_percentage+loss_percentage) > 47.0
@test win_percentage*100/(win_percentage+loss_percentage) < 53.0
println("Random vs random win: ", @sprintf("%0.2f", win_percentage),
        "%, losses: ", @sprintf("%0.2f", loss_percentage), "%",
        "%, draws: ",  @sprintf("%0.2f", draw_percentage), "%")

win_percentage, draw_percentage, loss_percentage = evaluate_tic_tac_toe_players(center_player, random_player, 10_000)
@test win_percentage*100/(win_percentage+loss_percentage) > 55.0
println("Center vs random win: ", @sprintf("%0.2f", win_percentage),
        "%, losses: ", @sprintf("%0.2f", loss_percentage), "%",
        "%, draws: ",  @sprintf("%0.2f", draw_percentage), "%")

q_table, q_player = train_q_learning_player()
win_percentage, draw_percentage, loss_percentage = evaluate_tic_tac_toe_players(q_player, random_player, 10_000)
@test win_percentage*100/(win_percentage+loss_percentage) > 75.0
println("Q player vs random win: ", @sprintf("%0.2f", win_percentage),
        "%, losses: ", @sprintf("%0.2f", loss_percentage), "%",
        "%, draws: ",  @sprintf("%0.2f", draw_percentage), "%")

opening = [q_table[(Int[0,0,0,0,0,0,0,0,0], 1, m)] for m=1:9]
for i=1:9
   println("Move ", i, ": ", @sprintf("%0.4f", opening[i]))
end