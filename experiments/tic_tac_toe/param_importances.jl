using DataFrames
using Gadfly
using MachineLearning

d = readtable("plots/randomize_parameters.csv")
d = d[d[:Opponent].=="rand",:]
delete!(d, :LossPercentage)
delete!(d, :DrawPercentage)
println(d)
draw(PNG("plots/randomize_parameters_importances_rf.png", 8inch, 6inch), plot(importances(d, :WinPercentage, regression_forest_options())))
draw(PNG("plots/randomize_parameters_importances_bart.png", 8inch, 6inch), plot(importances(d, :WinPercentage, bart_options())))
