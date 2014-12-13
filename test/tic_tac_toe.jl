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
