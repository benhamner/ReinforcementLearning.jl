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
        Game,
        hash,
        initialize_tic_tac_toe,
        isequal,
        perfect_player,
        play_tic_tac_toe,
        play_tic_tac_toe_random_first_move,
        possible_moves,
        random_player,
        TicTacToe,
        tic_tac_toe_to_input_features,
        train_q_learning_player,
        train_q_net_player,
        win_state

    include("common.jl")
    include("connect_four.jl")
    include("tic_tac_toe.jl")
end
