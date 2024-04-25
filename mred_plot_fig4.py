import matplotlib.pyplot as plt
from scipy.optimize import minimize
import numpy as np

n = 32
size = 1 / n

def objective(params, Mx, My):
    a, b, c = params
    # Your function F(Mx, My)
    numerator = abs((1 / (1 + My) + Mx / (1 + My)) - (a + b * My + c * Mx))
    denominator = abs((1 / (1 + My) + Mx / (1 + My)))
    return np.mean(np.abs((numerator / denominator)))

# Declare empty lists to store the data for plotting
c_values = []
objective_values = []

# Define initial guesses for parameters a, b, c
initial_guess = [0, 0, 0]

# Define ranges for My values
for j in range(1, 4):
    for k in range(1,9):
        avg_obj_val = 0.0
        for i in range(n):
            Mx_data = np.random.rand(100)
            My_data = np.random.rand(100) * size + (size * i)
            result = minimize(objective, initial_guess, args=(Mx_data, My_data))

            # Extract optimized parameters and round off to integer values
            a_opt, b_opt, c_opt = result.x
            
            a_opt = np.round(a_opt / (2 ** -7))
            b_opt = np.round(b_opt / (2 ** (-1 * 1)))
            c_opt = np.round(c_opt / (2 ** (-1 * 4)))

            # Calculate the objective value and accumulate it for averaging
            obj_val = objective([a_opt * 2 ** -7, b_opt * 2 ** (-1 * j), c_opt * 2 ** (-1 * k)], Mx_data, My_data)
            #obj_val = objective(result.x, Mx_data, My_data)
            avg_obj_val += obj_val

        # Calculate the average objective value and append it to the list
        avg_obj_val /= n
        if j==3:
            c_values.append((2 ** (-1 * k)))
            objective_values.append(obj_val/100)


objective_values_reversed = objective_values[::-1]
# Plotting
fig, ax = plt.subplots()
ax.plot(c_values[::-1], objective_values_reversed, marker='o')
ax.set_xlabel('LSBc')
ax.set_ylabel('MRED')
ax.set_title('MRED WRT LSBc @ CONSTANT LSBb')
ax.set_xscale('log', base=2)
ax.grid(True)
#yticks = np.arange(0, 0.051, 0.005)
#ax.set_yticks(yticks)


plt.show()
