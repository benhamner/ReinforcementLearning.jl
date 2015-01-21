using DataFrames
using Gadfly
using MachineLearning

d = readtable("plots/randomize_parameters.csv")
d = d[d[:Opponent].=="rand",:]
d[:LearningRates] = log10(d[:LearningRates])
delete!(d, :LossPercentage)
delete!(d, :DrawPercentage)
println(d)
draw(PNG("plots/randomize_parameters_importances_rf.png", 8inch, 6inch), plot(importances(d, :WinPercentage, regression_forest_options())))
draw(PNG("plots/randomize_parameters_partial_learning_rate_rf.png", 8inch, 6inch), plot(partials(d, :WinPercentage, :LearningRates, regression_forest_options())))
draw(PNG("plots/randomize_parameters_partial_num_games_rf.png", 8inch, 6inch), plot(partials(d, :WinPercentage, :NumGames, regression_forest_options())))

draw(PNG("plots/randomize_parameters_importances_bart.png", 8inch, 6inch), plot(importances(d, :WinPercentage, bart_options())))
draw(PNG("plots/randomize_parameters_partial_learning_rate_bart.png", 8inch, 6inch), plot(partials(d, :WinPercentage, :LearningRates, bart_options())))
draw(PNG("plots/randomize_parameters_partial_num_games_bart.png", 8inch, 6inch), plot(partials(d, :WinPercentage, :NumGames, bart_options())))
