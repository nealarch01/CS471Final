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
## Hyper-parameters
- Structure: [6, 2, 1]
  - Input layer 6 nodes
  - 1 Hidden layer 2 nodes
  - 1 Output layer 1 node
- Learning Rate: 0.65
- Target Error: 0.05

## Code Executions
Run 1: data.csv [1, 2, 3, 4, 5, 6, 7]
