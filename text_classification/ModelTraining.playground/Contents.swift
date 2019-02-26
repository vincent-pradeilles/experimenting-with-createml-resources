import Foundation
import CreateML
import NaturalLanguage

var data = try MLDataTable(contentsOf: Bundle.main.url(forResource: "movie-sentences", withExtension: "csv")!,
                           options: MLDataTable.ParsingOptions(containsHeader: true, delimiter: ";"))

let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)

let sentimentClassifier = try MLTextClassifier(trainingData: trainingData,
                                               textColumn: "text",
                                               labelColumn: "class")

// Training accuracy as a percentage
let trainingAccuracy = (1.0 - sentimentClassifier.trainingMetrics.classificationError) * 100

// Validation accuracy as a percentage
let validationAccuracy = (1.0 - sentimentClassifier.validationMetrics.classificationError) * 100

let evaluationMetrics = sentimentClassifier.evaluation(on: testingData)

// Evaluation accuracy as a percentage
let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100

let metadata = MLModelMetadata(author: "Vincent Pradeilles",
                               shortDescription: "A model trained to classify the sentiment of online movie reviews",
                               version: "1.0")

#error("Indicate real path before running")
try sentimentClassifier.write(to: URL(fileURLWithPath: "/path/to/save/MovieReview.mlmodel"),
                              metadata: metadata)
