// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation 

func readCSV(filepath: String) -> [[Double]]? {
    var contents: String = ""
    do {
        contents = try String(contentsOfFile: filepath, encoding: .utf8)
    } catch let error {
        print(error.localizedDescription)
        return nil
    }
    let lines = contents.split(separator: "\n")

    let matrix = lines.map { line in
        line.split(separator: ",").map { Double($0)! }
    }
    return matrix
}

let args = CommandLine.arguments
if args.count < 2 {
    print("Usage: swift main.swift <input file>")
    exit(1)
}

let filepath = args[1]
guard let data = readCSV(filepath: filepath) else {
    print("Failed to read file")
    exit(1)
}

print("Opened file")

let trainingInputs = data.map { Array($0[0..<data[0].count - 1]) }
let expectedOutputs = data.map { [$0[data[0].count - 1]] }

print("Initialized training inputs and expected outputs")

let networkTopology = NetworkTopology(layers: [6, 3, 1], collectors: [])
print("Initialized network topology")
let neuralNetwork = NeuralNetwork(topology: networkTopology)
print("Initialized neural network")

neuralNetwork.trainGeneratively(
    trainingInputs: trainingInputs,
    expectedOutputs: expectedOutputs,
    learningRate: 0.65,
    epochs: 500,
    targetError: 0.05
)


var predictInput: [Double] = [1, 2, 3, 4, 5, 6]
var expectedOutput = 7.0

var plotOutput: String = ""

for _ in 0..<5 {
    print("Predicting: \(predictInput) with expected output: \(expectedOutput)")
    let output = neuralNetwork.predict(row: predictInput, expectedOutput: expectedOutput)
    plotOutput += "(\(output.x),\(output.y))\n"
    predictInput = predictInput.map { $0 + 1 }
    expectedOutput += 1
}

print(plotOutput.dropLast())



