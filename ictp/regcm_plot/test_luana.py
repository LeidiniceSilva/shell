import numpy as np
import matplotlib.pyplot as plt

# generate 20 points from uniform (-3,3)
x = np.random.uniform(-3, 3, size=20)
y = np.sin(x)

fig, ax = plt.subplots()
ax.scatter(x,y)
plt.savefig("test.png")

