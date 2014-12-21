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

wins  = 0
draws = 0
num_samples = 10_000
for i=1:num_samples
   winner = play_tic_tac_toe_random_first_move(random_player, random_player)
   wins  += winner==1 ? 1 : 0
   draws += winner==3 ? 1 : 0
end
win_percentage = wins / num_samples * 100
draw_percentage = draws / num_samples * 100
loss_percentage = 100 - win_percentage - draw_percentage
@test draw_percentage < 20.0
@test draw_percentage > 5.0
@test win_percentage*100/(win_percentage+loss_percentage) > 47.0
@test win_percentage*100/(win_percentage+loss_percentage) < 53.0
println("Random vs random win: ", @sprintf("%0.2f", win_percentage),
        "%, losses: ", @sprintf("%0.2f", loss_percentage), "%",
        "%, draws: ",  @sprintf("%0.2f", draw_percentage), "%")

wins  = 0
draws = 0
num_samples = 10_000
for i=1:num_samples
   winner = play_tic_tac_toe_random_first_move(center_player, random_player)
   wins  += winner==1 ? 1 : 0
   draws += winner==3 ? 1 : 0
end
win_percentage = wins / num_samples * 100
draw_percentage = draws / num_samples * 100
loss_percentage = 100 - win_percentage - draw_percentage
@test win_percentage*100/(win_percentage+loss_percentage) > 55.0
println("Random vs random win: ", @sprintf("%0.2f", win_percentage),
        "%, losses: ", @sprintf("%0.2f", loss_percentage), "%",
        "%, draws: ",  @sprintf("%0.2f", draw_percentage), "%")
