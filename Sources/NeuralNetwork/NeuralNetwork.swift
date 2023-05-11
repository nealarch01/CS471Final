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
                print("epoch: \(epoch), learning rate: \(learningRate), error: \(sumError)")
                return
            }
            print("epoch: \(epoch), learning rate: \(learningRate), error: \(sumError)")
        }
    }

    private func shiftInputs(topInput: Double) {
        for i in (0..<layers[0].count - 1).reversed() {
            layers[0][i + 1].updateCollector(newCollector: layers[0][i].collector)
        }
        layers[0][0].updateCollector(newCollector: topInput)
    }

    public func trainGeneratively(trainingInputs: [[Double]], expectedOutputs: [[Double]], learningRate: Double, epochs: Int, targetError: Double) {
        // This function requires an output layer with only one node
        // 1. Train non-generative
        // 2. Generate new data
        // 3. Train generative
        // Make training inputs go through cosFn 
        let trainingInputsCpy = trainingInputs.map { $0.map { cosFn($0) } } // x
        var expectedOutputsCpy = expectedOutputs.map { $0.map { cosFn($0) } } // y
        print("Training generatively...")
        self.train(trainingInputs: trainingInputsCpy, expectedOutputs: expectedOutputsCpy, learningRate: learningRate, epochs: 250, targetError: targetError)
        print("Completed non-generative training")
        // print("Top input: \(self.layers[0][0].collector)")
        self.shiftInputs(topInput: self.outputsAverage())
        // print("Top input: \(self.layers[0][0].collector)")
        for _ in 0..<epochs {
            propagateForward()
            let outputY = outputsAverage() // This should be the collector, we are assuming that the output layer has only one node
            let error = pow(expectedOutputsCpy[0][0] - outputY, 2)
            print("given x: \(outputY), expected y: \(expectedOutputsCpy[0][0]), error: \(error)")
            propagateBackward(expectedOutputs: &expectedOutputsCpy[0])
            updateWeights(learningRate: learningRate)
            shiftInputs(topInput: outputsAverage())
        }
    }

    public func cosFn(_ x: Double) -> Double {
        return (cos(x) + 1) * 0.5
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

