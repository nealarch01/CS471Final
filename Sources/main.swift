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
if args.count < 3 {
    print("Usage: swift main.swift <input file> <prediction offset>")
    exit(1)
}

let filepath = args[1]
guard let data = readCSV(filepath: filepath) else {
    print("Failed to read file")
    exit(1)
}

print("Opened file")

let trainingInputs = data.map { Array($0.dropLast()) }
let expectedOutputs = data.map { [$0[data[0].count - 1]] }

print("Initialized training inputs and expected outputs")

let networkTopology = NetworkTopology(layers: [6, 3, 1], collectors: [])
print("Initialized network topology")
let neuralNetwork = NeuralNetwork(topology: networkTopology)
print("Initialized neural network")

guard let nextOffset = Double(args[2]) else {
    print("Invalid offset")
    exit(1)
}

let generated = neuralNetwork.trainGeneratively(
    trainingInputs: trainingInputs,
    expectedOutputs: expectedOutputs,
    learningRate: 0.60,
    epochs: 250,
    targetError: 0.009,
    newRows: 10,
    offsetBy: nextOffset // This changes the expected output once the network has learned inputs
)


print("Generated \(generated.count) new rows of data")
print("\nGenerated: ")
for row in generated {
    print(row)
}

let generatedInputs = generated.map { Array($0.dropLast()) }
let generatedOutputs = generated.map { [$0[generated[0].count - 1]] }



neuralNetwork.train(
    trainingInputs: generatedInputs,
    expectedOutputs: generatedOutputs,
    learningRate: 0.60,
    epochs: 250,
    targetError: 0.009
)

var predictInput: [Double] = trainingInputs[0]
var expectedOutput = expectedOutputs[0][0]

var plotOutput: String = ""

for _ in 0..<20 {
    print("Input: \(predictInput) with expected output: \(expectedOutput)")
    let output = neuralNetwork.predict(row: predictInput, expectedOutput: expectedOutput)
    print("") // Print a newline, empty string but the terminator will print a newline
    plotOutput += "(\(expectedOutput),\(output.y))\n"
    predictInput = predictInput.map { $0 + nextOffset } // Increments all elements by 1
    expectedOutput += nextOffset
}


print("Plot points:")
print(plotOutput.dropLast())
