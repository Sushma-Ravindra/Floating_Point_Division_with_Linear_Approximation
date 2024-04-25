from scipy.optimize import minimize
import numpy as np

# Define the objective function
def objective(params, Mx, My):
    a, b, c = params
    # Your function F(Mx, My)
    numerator = abs((1/(1+My) + Mx/(1+My)) - (a + b*My + c*Mx))
    denominator = abs((1/(1+My) + Mx/(1+My)))
    return np.mean(numerator / denominator)

# Define initial guesses for parameters a, b, c
initial_guess = [0, 0, 0]

# Define ranges for My values
for i in range(16):
    Mx_data = np.random.rand(1000000)
    My_data = np.random.rand(1000000) * 0.0625 + (0.0625 * i)
    start = 0.25 * i
    end = 0.25 * (i + 1)
    result = minimize(objective, initial_guess, args=(Mx_data, My_data))

    # Extract optimized parameters and round off to integer values
    a_opt, b_opt, c_opt = result.x
    a_opt = int(round(a_opt / (2**-7)))
    b_opt = int(round(b_opt / (2**-1)))
    c_opt = int(round(c_opt / (2**-4)))

    print(f"Range {i+1}: My from {start} to {end}")
    print("Optimized Parameters:")
    print("a:", a_opt)
    print("b:", b_opt)
    print("c:", c_opt)
    print()
