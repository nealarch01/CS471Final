import Foundation

struct NeuralNetwork: Codable {
    private(set) var layers: [[Node]] = []
    var lastIndex: Int? { 
        if layers.count == 0 { return nil }
        return layers.count - 1 
    }
    var layerCount: Int { return layers.count }

    init(topology: NetworkTopology) {
        // Create the first layer 
        let firstLayer = createLayer(size: topology.layers[0], collectors: Array(repeating: 0.0, count: topology.layers[0]))
        layers.append(firstLayer)

        for i in 1..<topology.layers.count {
            let collectorSummation = layerSummation(atIndex: i - 1)
            let column = createLayer(
                size: topology.layers[i], 
                collectors: Array(
                    repeating: collectorSummation, 
                    count: topology.layers[i]
            ))
            layers.append(column) 
        }
    }

    mutating private func createLayer(size: Int, collectors: [Double]) -> [Node] {
        var column: [Node] = []
        for i in 0..<size {
            let newNode = Node(collector: collectors[i])
            // Go to the previous layer
            if lastIndex ?? -1 >= 0 {
                for i in 0..<layers[lastIndex!].count {
                    layers[lastIndex!][i].addConnection(node: newNode)
                }
            }
            column.append(newNode)
        }
        return column
    }

    public func printColumn(atIndex: Int) {
        if atIndex > lastIndex! {
            print("Layer does not exist")
            return
        }
        for node in layers[atIndex] {
            node.display()
        }
    }
    
    public func outputs() -> [Double] {
        return layers[layers.count - 1].map { $0.collector }
    }
    
    public func outputsAverage() -> Double {
        var sum = 0.0
        let numberOfOutputs = layers[layers.count - 1].count
        for i in 0..<numberOfOutputs {
            sum += layers[layers.count - 1][i].collector
        }
        return sum / Double(numberOfOutputs)
    }

    public func printLayers() {
        if layers.count == 0 {
            print("The network is empty")
            return
        }
        for index in 0..<layers.count {
            printColumn(atIndex: index)
        }
    }

    private func layerSummation(atIndex: Int) -> Double {
        var sum: Double = 0.0
        for node in layers[atIndex] {
            sum += node.collector
        }
        return sum
    }

    private func setInputLayer(trainingInputs: inout [Double]) {
        if trainingInputs.count < layers[0].count - 1{
            var trainingInputsFixed = trainingInputs // if the number of training data is less than the number of input layers, append 0
            for _ in trainingInputsFixed.count..<layers[0].count {
                trainingInputsFixed.append(0.0)
            }
             for i in 0..<layers[0].count {
                layers[0][i].updateCollector(newCollector: trainingInputsFixed[i])
            }
        }
        for i in 0..<layers[0].count {
            layers[0][i].updateCollector(newCollector: trainingInputs[i])
        }
    }

    private func transfer(activation: Double) -> Double {
        return 1.0 / (1.0 + exp(-activation))
    }

    private func propagateForward() {
        for layerIndex in 1..<layers.count {
            for currentNodeIndex in 0..<layers[layerIndex].count {
                var weightedSum: Double = 0.0
                for previousNodeIndex in 0..<layers[layerIndex - 1].count {
                    weightedSum += layers[layerIndex - 1][previousNodeIndex].collector * layers[layerIndex - 1][previousNodeIndex].connections[currentNodeIndex].weight
                }
                layers[layerIndex][currentNodeIndex].updateCollector(newCollector: transfer(activation: weightedSum))
            }
        }
    }

    private func transferDerivative(collector: Double) -> Double {
        return collector * (1.0 - collector)
    }

   private func propagateBackward(expectedOutputs: inout [Double]) {
        for layerIndex in (0..<layers.count).reversed() {
            var errors: [Double] = []
            if layerIndex != layers.count - 1 { // if we are not at the output layer
                for nodeIndex in 0..<layers[layerIndex].count {
                    var error: Double = 0.0
                    for nextNodeIndex in 0..<layers[layerIndex + 1].count {
                        let weight = layers[layerIndex][nodeIndex].connections[nextNodeIndex].weight
                        let delta = layers[layerIndex + 1][nextNodeIndex].delta
                        error += (weight * delta)
                    }
                    errors.append(error)
                }
            } else { // if we are at the output layer
                for nodeIndex in 0..<layers[layerIndex].count {
                    let collector = layers[layerIndex][nodeIndex].collector
                    let error = collector - expectedOutputs[nodeIndex]
                    errors.append(error)
                }
            }
            for nodeIndex in 0..<layers[layerIndex].count {
                let delta = errors[nodeIndex] * transferDerivative(collector: layers[layerIndex][nodeIndex].collector)
                layers[layerIndex][nodeIndex].updateDelta(newDelta: delta) 
            }
        }
    }

    private func updateWeights(learningRate: Double) {
        // General formula: weight = weight - learningRate * delta * collectorFromPreviousLayer
        for layerIndex in 1..<layers.count {
            let inputs: [Double] = layers[layerIndex - 1].map { $0.collector }
            for currentLayerNodeIndex in 0..<layers[layerIndex].count {
                for prevLayerNodeIndex in 0..<layers[layerIndex - 1].count {
                    let weight = layers[layerIndex - 1][prevLayerNodeIndex].connections[currentLayerNodeIndex].weight
                    let delta = layers[layerIndex][currentLayerNodeIndex].delta
                    let collector = inputs[prevLayerNodeIndex]
                    let newWeight = weight - learningRate * delta * collector
                    layers[layerIndex - 1][prevLayerNodeIndex].connections[currentLayerNodeIndex].updateWeight(newWeight: newWeight)
                }
            }
        }
    }

    public func train(trainingInputs: [[Double]], expectedOutputs: [[Double]], learningRate: Double, epochs: Int, targetError: Double) {
        var trainingInputsCpy = trainingInputs
        var expectedOutputsCpy = expectedOutputs
        for epoch in 0..<epochs {
            var sumError: Double = 0.0
            for j in 0..<trainingInputs.count {
                setInputLayer(trainingInputs: &trainingInputsCpy[j])
                propagateForward()
                let outputs = layers.last!.map { $0.collector }
                for k in 0..<outputs.count {
                    // Add sum error here
                    let error = expectedOutputsCpy[j][k] - outputs[k]
                    sumError += pow(error, 2)
                }
                propagateBackward(expectedOutputs: &expectedOutputsCpy[j])
                updateWeights(learningRate: learningRate)
            }
            if sumError <= targetError {
                print("Target error reached")
                print("> Epoch: \(epoch), Learning Rate: \(learningRate), Error: \(sumError)")
                return
            }
            print("> Epoch: \(epoch), Learning Rate: \(learningRate), Error: \(sumError)")
        }
    }

    private func shiftInputs(newInput: Double) {
        /*
        [f(1) => f(2)]
        [f(2) => f(3)]
        [f(3) => f(4)]
        [f(4) => f(5)]
        */
        for i in 0..<layers[0].count - 1 {
            layers[0][i].updateCollector(newCollector: layers[0][i + 1].collector)
        }
        layers[0][layers[0].count - 1].updateCollector(newCollector: newInput)
    }

    public func trainGeneratively(trainingInputs: [[Double]], expectedOutputs: [[Double]], learningRate: Double, epochs: Int, targetError: Double, newRows: Int, offsetBy: Double) {
        // This function requires an output layer with only one node
        // 1. Train non-generative
        // 2. Generate new data
        // 3. Train generative
        // 4. 😰
        let trainingInputsCpy = trainingInputs.map { $0.map { cosFn($0) } } // x
        let expectedOutputsCpy = expectedOutputs.map { $0.map { cosFn($0) } } // y
        var expectedOutput = expectedOutputs[0][0] // This is assuming that the output layer has only one node

        self.train(trainingInputs: trainingInputsCpy, expectedOutputs: expectedOutputsCpy, learningRate: learningRate, epochs: 250, targetError: targetError)

        let initialOutput = outputsAverage() // This assumes that the output layer has only one node
        // red ansi color code: \u{001B}[0;31m
        print("\u{001B}[0;31mStarting generative training\u{001B}[0;0m")
        print("=========================================")

        var generatedInputs: [[Double]] = []
        generatedInputs.append(layers[0].map { $0.collector } + [cosFn(expectedOutput)])

        shiftInputs(newInput: initialOutput) // Puts the first output in the input layer and shifts the rest of the inputs down
        expectedOutput += offsetBy // Change the expected output

        for _ in 0..<newRows {
            for epoch in 0..<epochs {
                // let givenX = layers[0][layers[0].count - 1].collector
                propagateForward()
                let expected = cosFn(expectedOutput)
                let error = sqrt(pow(expected - outputsAverage(), 2))
                if error <= targetError {
                    print(">> Epoch: \(epoch), Learning Rate: \(learningRate), Error: \(error)")
                    break
                }
                var newExpectedOutputs = [expected]
                propagateBackward(expectedOutputs: &newExpectedOutputs)
                updateWeights(learningRate: learningRate)
                print(">> Epoch: \(epoch), Learning Rate: \(learningRate), Error: \(error)")
            }
            generatedInputs.append(layers[0].map { $0.collector } + [cosFn(expectedOutput)])
            shiftInputs(newInput: outputsAverage())
            print("> Created new row: \(generatedInputs.last!)")
            expectedOutput += offsetBy
        }

        print("\n")
        for gi in generatedInputs {
            print(gi)
        }
        print("\n")
    }

    public func cosFn(_ x: Double) -> Double {
        return (cos(x) + 1) * 0.5
    }

    public func predict(row: [Double], expectedOutput: Double) -> (x: Double, y: Double) {
        var rowCosined = row.map { cosFn($0) }
        setInputLayer(trainingInputs: &rowCosined)
        propagateForward()
        let output = outputsAverage()
        let error = sqrt(pow(cosFn(expectedOutput) - output, 2))
        print("given x: \(row[0]), generated y: \(output), predicted y: \(cosFn(expectedOutput)), error: \(error)")
        return (
            x: rowCosined[0],
            y: output
        )
    }

    public func test(inputs: [[Double]]) -> Double {
        var inputsCpy = inputs
        var outputs: [[Double]] = []
        for i in 0..<inputs.count {
            setInputLayer(trainingInputs: &inputsCpy[i])
            propagateForward()
            let output = layers.last!.map { $0.collector }
            outputs.append(output)
        }
        return outputsAverage()
    }

    public func serialize() -> String? {
        // Pretty print the JSON
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        guard let data = try? jsonEncoder.encode(self) else {
            print("An error occurred while serializing the network")
            return nil
        }
        let string = String(data: data, encoding: .utf8)
        return string
    }
}

