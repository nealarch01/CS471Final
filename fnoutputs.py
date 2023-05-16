from math import cos, acos

def cosFn(x):
    return (cos(x) + 1) * 0.5

plotPoints = ""

for i in range(1, 17):
    x = cosFn(i)
    y = cosFn(x)
    print(f"i: {i}, x: {x}, y: {y}")
    plotPoints += f"({x}, {y})\n"

print(plotPoints)

