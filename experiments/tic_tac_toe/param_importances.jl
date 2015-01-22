using DataFrames
using Gadfly
using MachineLearning

d = readtable("plots/randomize_parameters.csv")
d = d[d[:Opponent].=="rand",:]
d[:LearningRates] = log10(d[:LearningRates])
delete!(d, :LossPercentage)
delete!(d, :DrawPercentage)
d[:HiddenLayer] = [eval(parse(l)) for l=d[:HiddenLayer]]
d[:NumHiddenLayers] = [float(length(l)) for l = d[:HiddenLayer]]
d[:SizeFirstLayer] = [float(l[1]) for l = d[:HiddenLayer]]
println(d[1:10,:])
delete!(d, :HiddenLayer)
delete!(d, :Opponent)

features = filter(n -> n!=:WinPercentage, names(d))
println(features)

draw(PNG("plots/partials/randomize_parameters_importances_rf.png", 8inch, 6inch), plot(importances(d, :WinPercentage, regression_forest_options())))
draw(PNG("plots/partials/randomize_parameters_importances_bart.png", 8inch, 6inch), plot(importances(d, :WinPercentage, bart_options())))

for f = features
    draw(PNG(@sprintf("plots/partials/randomize_parameters_partial_%s_rf.png", f), 8inch, 6inch), plot(partials(d, :WinPercentage, f, regression_forest_options())))
    draw(PNG(@sprintf("plots/partials/randomize_parameters_partial_%s_bart.png", f), 8inch, 6inch), plot(partials(d, :WinPercentage, f, bart_options())))
end

