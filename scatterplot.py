import matplotlib.pyplot as plt
from scipy.optimize import minimize
import numpy as np

n = 4
size = 1 / n

def objective1(params, Mx, My):
    a, b, c = params
    # Your function F(Mx, My)
    numerator = abs((1 / (1 + My) + Mx / (1 + My)) - (a + b * My + c * Mx))
    denominator = abs((1 / (1 + My) + Mx / (1 + My)))
    return np.abs((numerator / denominator))

def objective(params, Mx, My):
    a, b, c = params
    # Your function F(Mx, My)
    numerator = abs((1 / (1 + My) + Mx / (1 + My)) - (a + b * My + c * Mx))
    denominator = abs((1 / (1 + My) + Mx / (1 + My)))
    return np.mean(np.abs((numerator / denominator)))

# Declare empty lists to store the data for plotting
objective_values = []
Mx = []
My = []

# Define initial guesses for parameters a, b, c
initial_guess = [0, 0, 0]

# Define ranges for My values
for i in range(n):
    Mx_data = np.linspace(0, 1, 100)
    My_data = np.linspace(size * i, size * (i + 1), 20)
    Mx.append(Mx_data)
    My.append(My_data)
    
    Mx_grid, My_grid = np.meshgrid(Mx_data, My_data)
    
    plt.figure(figsize=(8, 6))
    plt.scatter(Mx_grid, My_grid, color='red', label='Data points')
    plt.xlabel('Mx')
    plt.ylabel('My')
    plt.title(f'Scatter Plot for i={i}')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f'scatter_plot_i_{i}.png', dpi=300, bbox_inches='tight')  # Save the plots as an image
    plt.show()
