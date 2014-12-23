module ReinforcementLearning
    # using
        # nothing at the moment

    export
        center_player,
        evaluate_tic_tac_toe_players,
        Game,
        initialize_tic_tac_toe,
        play_tic_tac_toe,
        play_tic_tac_toe_random_first_move,
        possible_moves,
        random_player,
        TicTacToe,
        train_q_learning_player,
        win_state

    include("common.jl")
    include("tic_tac_toe.jl")
end
