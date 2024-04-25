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
    
    for j in range(len(Mx_data)):
        result = minimize(objective, initial_guess, args=(Mx_data[j], My_data))

        # Extract optimized parameters and round off to integer values
        #a_opt, b_opt, c_opt = result.x
        #a_opt = np.round(a_opt / (2 ** -7))
        #b_opt = np.round(b_opt / (2 ** (-1 * 1)))
        #c_opt = np.round(c_opt / (2 ** (-1 * 4)))

        # Calculate the objective value and append it to the list
        
        #if (i==0):
        a_opt=131
        b_opt=(-2)
        c_opt=(7)
        #elif (i==1):
        #    a_opt=139
        #    b_opt=(-2)
        #    c_opt=(6)
        #elif (i==2):
        #    a_opt=118
        #    b_opt=(-1)
        #    c_opt=(5)
        #else:
        #    a_opt=128
        #    b_opt=(-1)
        #    c_opt=(4)
        




        obj_val = objective1([a_opt * 2 ** -7, (b_opt) * 2 ** (-1 * 1), c_opt * 2 ** (-1 * 3)], Mx_data[j], My_data)
        objective_values.append(obj_val)

# Reshape objective_values to create RED_N4
RED_N4 = np.reshape(objective_values, (n, -1, len(Mx[0])))

# Plotting contour plots for N=4
plt.figure(figsize=(10, 8))
levels = np.arange(0, 0.051, 0.005)

for k in range(n):
    plt.contourf(Mx[k], My[k], RED_N4[k], levels=levels, cmap='Blues_r', alpha=0.8)

# Set the color for zero error to dark blue
#min_level = levels.min()
#zero_levels = np.linspace(0, min_level, 1)
#plt.contourf(Mx[0], My[0], RED_N4[0], levels=zero_levels, colors=['navy'], alpha=0.8)

plt.ylabel('Y', fontsize=12)
plt.xlabel('X', fontsize=12)
plt.title('Contour Plot of RED for N=4', fontsize=14)
plt.colorbar(label='RED', ticks=np.arange(0, 0.051, 0.005))
plt.yticks(np.arange(0, 1.1, 0.1))
#plt.grid(True)

plt.tight_layout()
plt.savefig('contour_plots.png', dpi=300, bbox_inches='tight')  # Save the plots as an image
plt.show()
