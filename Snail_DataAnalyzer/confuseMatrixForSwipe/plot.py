import numpy as np
import matplotlib.pyplot as plt
import os

m = np.array([[0.88, 0.03, 0.04, 0.04, 0.01],[0.01, 0.95, 0.01, 0.01, 0.02],[0.01, 0.02, 0.88, 0.05, 0.04],[0.00, 0.02, 0.01, 0.96, 0.01],[0.00, 0.00, 0.01, 0.00, 0.99]])

plt.matshow(m)
plt.colorbar()

# raw_input()
# plt.savefig(pp, format='pdf')