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
- Epochs 250

## Code Executions
### Run 1: data.csv [1, 2, 3, 4, 5, 6, 7]

<img width="1221" alt="Screenshot 2023-05-14 at 8 34 04 PM" src="https://github.com/nealarch01/GenerativeArtificialNeuralNetwork/assets/73256760/34350ea2-defe-4bce-a27a-86bed6da14e5">

(x, y) outputs
```swift
(0.7701511529340699,0.8850137966710818)
(0.2919265817264288,0.890720772117735)
(0.005003751699777292,0.8971648427716771)
(0.17317818956819403,0.898599339659303)
(0.6418310927316131,0.8939878658309475)
(0.9800851433251829,0.88715908618512)
```

<img width="809" alt="Screenshot 2023-05-14 at 8 33 36 PM" src="https://github.com/nealarch01/GenerativeArtificialNeuralNetwork/assets/73256760/caea5b48-822b-4015-8363-ae323a42f8e3">



### Run 2: even.csv

<img width="872" alt="Screenshot 2023-05-14 at 8 36 43 PM" src="https://github.com/nealarch01/GenerativeArtificialNeuralNetwork/assets/73256760/1be97e64-969c-42f8-8a4d-f4b0d1e81f4a">

(x, y) outputs
```swift
(0.2919265817264288,0.1029997371630104)
(0.17317818956819403,0.09596249749165511)
(0.9800851433251829,0.09077621456108553)
(0.42724998309569323,0.10181899644566461)
(0.08046423546177378,0.09783118243301746)
(0.9219269793662461,0.09034941307969228)
```


<img width="808" alt="Screenshot 2023-05-14 at 8 30 54 PM" src="https://github.com/nealarch01/GenerativeArtificialNeuralNetwork/assets/73256760/97794b86-f0dd-4daa-9bac-3f1d058e0a8e">



