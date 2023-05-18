# CS 471 Final


# Build Instructions
## Pre-requisites
1. Swift Compiler
   - [Installation Guide](https://www.swift.org/getting-started/)
   - Note: The swift compiler is cross-platform and can be used in Linux and Windows
   - Another note: Swift is not installed by default on MacOS

## Build Steps
1. Clone this repo `git clone https://github.com/nealarch01/GenerativeArtificialNeuralNetwork`
2. Navigate into repo directory
3. Run `./build.sh` to build the executable

# Usage:
#### `./GANN <input_file.csv>`
- To test with inputs [1, 2, 3, 4, 5, 6, 7]: `./GANN data.csv`

# Program Outputs:
Note: outputs can be viewed in output*.txt
## Hyperparameters
- Structure: [6, 2, 1]
  - Input layer 6 nodes
  - 1 Hidden layer 2 nodes
  - 1 Output layer 1 node
- Learning Rate: 0.6
- Target Error: 0.001
- Epochs 250
- Additional Generated Data: 10 rows



## Code Executions
### Run 1: data.csv [1, 2, 3, 4, 5, 6, 7]
<img width="1470" alt="Screenshot 2023-05-17 at 8 10 53 PM" src="https://github.com/nealarch01/GenerativeArtificialNeuralNetwork/assets/73256760/d10741a5-0bd9-4dd6-a798-c4636c8020d8">




### Run 2: even.csv [2, 4, 6, 8, 10, 12, 14]
<img width="1465" alt="Screenshot 2023-05-17 at 8 38 45 PM" src="https://github.com/nealarch01/GenerativeArtificialNeuralNetwork/assets/73256760/849aa454-d462-450d-bc64-ef615859685f">
