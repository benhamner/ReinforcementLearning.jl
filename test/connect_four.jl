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
                             0 0 0 0 0 1;
                             0 0 0 0 1 1;
                             2 2 2 2 1 1])) == 2
