using Base.Test
using ReinforcementLearning

@test hash(TicTacToe([0,2,0,0,1,0,0,0,0]))==hash(TicTacToe([0,2,0,0,1,0,0,0,0]))
@test isequal(TicTacToe([0,2,0,0,1,0,0,0,0]), TicTacToe([0,2,0,0,1,0,0,0,0]))
@test TicTacToe([0,2,0,0,1,0,0,0,0])==TicTacToe([0,2,0,0,1,0,0,0,0])

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

@test move!(TicTacToe([0,0,0,0,0,0,0,0,0]), 1, 5)==TicTacToe([0,0,0,0,1,0,0,0,0])
@test move!(TicTacToe([0,0,0,0,1,0,0,0,0]), 2, 1)==TicTacToe([2,0,0,0,1,0,0,0,0])

@test evaluate_board(TicTacToe([0,1,1,0,2,2,0,0,0]), 1)[1]==1
@test evaluate_board(TicTacToe([0,1,1,0,2,2,0,0,0]), 2)[1]==2
@test evaluate_board(TicTacToe([0,1,1,0,0,2,0,0,0]), 1)[1]==1
@test evaluate_board(TicTacToe([0,1,0,0,0,2,0,0,0]), 1)[1]==1
@test evaluate_board(TicTacToe([0,1,0,0,0,0,0,0,0]), 1)[1]==1
@test evaluate_board(TicTacToe([0,0,0,0,0,0,0,0,0]), 1)[1]==3
@test evaluate_board(TicTacToe([1,0,0,0,1,0,1,2,2]), 2)[1]==1

@test game_to_input_features(TicTacToe([0,0,0,0,0,0,0,0,0]), 1, 1)==[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
@test game_to_input_features(TicTacToe([0,0,0,0,0,0,0,0,1]), 2, 1)==[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
@test game_to_input_features(TicTacToe([2,0,0,0,0,0,0,0,1]), 1, 1)==[1,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0]
@test game_to_input_features(TicTacToe([2,0,0,0,1,0,0,2,1]), 1, 2)==[0,1,0,0,1,0,0,0,1,1,0,0,0,0,0,0,1,0]

win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(random_player, random_player, 10_000)
@test draw_percentage < 20.0
@test draw_percentage > 5.0
@test win_percentage*100/(win_percentage+loss_percentage) > 47.0
@test win_percentage*100/(win_percentage+loss_percentage) < 53.0
println("Random vs random: ", results_txt)

win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(center_player, random_player, 10_000)
@test win_percentage*100/(win_percentage+loss_percentage) > 55.0
println("Center vs random: ", results_txt)

win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(perfect_player, random_player, 10_000)
@test win_percentage*100/(win_percentage+loss_percentage) > 55.0
println("Perfct vs random: ", results_txt)

q_table, q_player = train_q_learning_player()
win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_player, random_player, 10_000)
@test win_percentage*100/(win_percentage+loss_percentage) > 75.0
println("Q player vs random: ", results_txt)

win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_player, perfect_player, 10_000)
@test draw_percentage > 50.0
println("Q player vs perfect: ", results_txt)

q_net, q_net_player = train_q_net_player(play_tic_tac_toe_track_state, 18, [random_player, perfect_player])
win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_tic_tac_toe_players(q_net_player, random_player, 10_000)
@test win_percentage*100/(win_percentage+loss_percentage) > 60.0
println("Q net vs random: ", results_txt)
