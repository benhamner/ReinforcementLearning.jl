module ReinforcementLearning
    using
        DataStructures,
        MachineLearning

    export
        center_player,
        command_player,
        ConnectFour,
        evaluate_board,
        evaluate_tic_tac_toe_players,
        evaluate_connect_four_players,
        game_to_input_features,
        Game,
        hash,
        initialize_tic_tac_toe,
        isequal,
        make_lookahead_player,
        move!,
        perfect_player,
        play_connect_four,
        play_connect_four_random_first_move,
        play_tic_tac_toe,
        play_tic_tac_toe_random_first_move,
        possible_moves,
        random_player,
        TicTacToe,
        train_q_learning_player,
        train_q_net_player,
        win_state

    include("common.jl")
    include("connect_four.jl")
    include("tic_tac_toe.jl")
end
