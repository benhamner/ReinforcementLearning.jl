using Base.Test
using ReinforcementLearning

cf1 = ConnectFour([0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0;
                   0 0 2 1 0 0 0])

cf2 = ConnectFour([0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0;
                   0 0 2 1 0 0 0])

@test hash(cf1)==hash(cf2)
@test isequal(cf1,cf2)
@test cf1==cf2

@test win_state(ConnectFour([0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             0 0 2 1 0 0 0])) == 0

@test win_state(ConnectFour([0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             0 0 0 1 0 0 0;
                             0 0 2 1 0 0 0;
                             0 0 2 1 0 0 0;
                             0 0 2 1 0 0 0])) == 1

@test win_state(ConnectFour([0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             1 0 0 0 0 0 0;
                             2 1 0 0 0 0 0;
                             1 1 1 0 0 0 0;
                             2 2 2 1 2 0 0])) == 1

@test win_state(ConnectFour([0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             0 0 0 0 0 0 0;
                             0 0 0 0 1 1 0;
                             2 2 2 2 1 1 0])) == 2

@test win_state(ConnectFour([1 2 2 1 1 1 2;
                             2 1 1 2 2 2 1;
                             1 2 1 1 1 2 2;
                             2 1 1 2 2 1 1;
                             1 2 2 1 1 1 2;
                             2 2 1 2 1 1 2])) == 3

@test win_state(ConnectFour([2 2 2 2 1 1 2;
                             2 1 1 2 2 2 1;
                             1 2 1 1 1 2 2;
                             2 1 1 2 2 1 1;
                             1 2 2 1 1 1 2;
                             2 2 1 2 1 1 2])) == 2

@test win_state(ConnectFour([2 1 2 1 1 1 2;
                             2 1 1 2 2 2 1;
                             1 2 1 1 2 2 2;
                             2 1 1 2 2 2 1;
                             1 2 2 1 1 1 2;
                             2 2 1 2 1 1 2])) == 2

@test possible_moves(ConnectFour([0 0 0 0 0 0 0;
                                  0 0 0 0 0 0 0;
                                  0 0 0 0 0 0 0;
                                  0 0 0 0 0 0 0;
                                  0 0 0 0 0 0 0;
                                  0 0 2 1 0 0 0])) == [1, 2, 3, 4, 5, 6, 7]

@test possible_moves(ConnectFour([2 1 2 1 1 1 2;
                                  2 1 1 2 2 2 2;
                                  1 2 1 1 2 2 1;
                                  2 1 1 2 2 2 2;
                                  1 2 2 1 1 1 1;
                                  2 2 1 2 1 1 2])) == Int[]

@test possible_moves(ConnectFour([0 1 0 0 1 1 1;
                                  2 1 1 2 2 2 2;
                                  1 2 1 1 2 2 2;
                                  2 1 1 2 2 2 1;
                                  1 2 2 1 1 1 1;
                                  2 2 1 2 1 1 2])) == [1,3,4]

@test possible_moves(ConnectFour([0 1 0 0 1 0 0;
                                  2 1 0 2 2 2 0;
                                  1 2 0 1 2 2 0;
                                  2 1 0 2 2 2 0;
                                  1 2 2 1 1 1 0;
                                  2 2 1 2 1 1 0])) == [1,3,4,6,7]

@test move!(ConnectFour([0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;]), 1, 4)==
            ConnectFour([0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;
                         0 0 0 0 0 0 0;
                         0 0 0 1 0 0 0;])

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(random_player, random_player, 10_000)
println("Random vs random: ", results_txt)
@test win_percentage*100/(win_percentage+loss_percentage) > 40.0
@test win_percentage*100/(win_percentage+loss_percentage) < 60.0

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(make_lookahead_player(0), random_player, 100)
println("Lookahead0 vs random: ", results_txt)
@test win_percentage*100/(win_percentage+loss_percentage) > 40.0
@test win_percentage*100/(win_percentage+loss_percentage) < 60.0

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(make_lookahead_player(1), random_player, 100)
println("Lookahead1 vs random: ", results_txt)
@test win_percentage*100/(win_percentage+loss_percentage) > 65.0

@time win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(make_lookahead_player(2), random_player, 100)
println("Lookahead2 vs random: ", results_txt)
@test win_percentage*100/(win_percentage+loss_percentage) > 80.0
