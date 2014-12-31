using Base.Test
using ReinforcementLearning

cf1 = ConnectFour([0 0 0 0 0 0;
                   0 0 0 0 0 0;
                   0 0 0 0 0 0;
                   0 0 0 0 0 0;
                   0 0 0 0 0 0;
                   0 0 2 1 0 0])

cf2 = ConnectFour([0 0 0 0 0 0;
                   0 0 0 0 0 0;
                   0 0 0 0 0 0;
                   0 0 0 0 0 0;
                   0 0 0 0 0 0;
                   0 0 2 1 0 0])

@test hash(cf1)==hash(cf2)
@test isequal(cf1,cf2)
@test cf1==cf2

@test win_state(ConnectFour([0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 2 1 0 0])) == 0

@test win_state(ConnectFour([0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 0 1 0 0;
                             0 0 2 1 0 0;
                             0 0 2 1 0 0;
                             0 0 2 1 0 0])) == 1

@test win_state(ConnectFour([0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             1 0 0 0 0 0;
                             2 1 0 0 0 0;
                             1 1 1 0 0 0;
                             2 2 2 1 2 0])) == 1

@test win_state(ConnectFour([0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 0 0 0 0;
                             0 0 0 0 1 1;
                             2 2 2 2 1 1])) == 2

@test win_state(ConnectFour([1 2 2 1 1 1;
                             2 1 1 2 2 2;
                             1 2 1 1 1 2;
                             2 1 1 2 2 1;
                             1 2 2 1 1 1;
                             2 2 1 2 1 1])) == 3

@test win_state(ConnectFour([2 2 2 2 1 1;
                             2 1 1 2 2 2;
                             1 2 1 1 1 2;
                             2 1 1 2 2 1;
                             1 2 2 1 1 1;
                             2 2 1 2 1 1])) == 2

@test win_state(ConnectFour([2 1 2 1 1 1;
                             2 1 1 2 2 2;
                             1 2 1 1 2 2;
                             2 1 1 2 2 2;
                             1 2 2 1 1 1;
                             2 2 1 2 1 1])) == 2

@test possible_moves(ConnectFour([0 0 0 0 0 0;
                                  0 0 0 0 0 0;
                                  0 0 0 0 0 0;
                                  0 0 0 0 0 0;
                                  0 0 0 0 0 0;
                                  0 0 2 1 0 0])) == [1, 2, 3, 4, 5, 6]

@test possible_moves(ConnectFour([2 1 2 1 1 1;
                                  2 1 1 2 2 2;
                                  1 2 1 1 2 2;
                                  2 1 1 2 2 2;
                                  1 2 2 1 1 1;
                                  2 2 1 2 1 1])) == Int[]

@test possible_moves(ConnectFour([0 1 0 0 1 1;
                                  2 1 1 2 2 2;
                                  1 2 1 1 2 2;
                                  2 1 1 2 2 2;
                                  1 2 2 1 1 1;
                                  2 2 1 2 1 1])) == [1,3,4]

@test possible_moves(ConnectFour([0 1 0 0 1 0;
                                  2 1 0 2 2 2;
                                  1 2 0 1 2 2;
                                  2 1 0 2 2 2;
                                  1 2 2 1 1 1;
                                  2 2 1 2 1 1])) == [1,3,4,6]

win_percentage, draw_percentage, loss_percentage, results_txt = evaluate_connect_four_players(random_player, random_player, 10_000)
println("Random vs random: ", results_txt)
