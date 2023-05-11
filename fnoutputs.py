from math import cos

def cosFn(x):
    return (cos(x) + 1) * 0.5


for i in range(1, 17):
    print(f"{i} = {cosFn(i)}")
