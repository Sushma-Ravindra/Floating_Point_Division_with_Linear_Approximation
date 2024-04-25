from scipy.optimize import minimize
import numpy as np
import matplotlib.pyplot as plt

n= 4
size = 1/n
objective_values=[]
# Define the objective function
def objective(params, Mx, My):
    a, b, c = params
    # Your function F(Mx, My)
    numerator = abs((1/(1+My) + Mx/(1+My)) - (a + b*My + c*Mx))
    denominator = abs((1/(1+My) + Mx/(1+My)))
    return np.mean(np.abs((numerator / denominator)))

# Define initial guesses for parameters a, b, c
initial_guess = [0, 0, 0]
obj_val=[]

# Define ranges for My values
for i in range(n):


            Mx_data = np.random.rand(20000)
            My_data = np.random.rand(20000) * size + (size * i)
            start = size * i
            end = size * (i + 1)
            result = minimize(objective, initial_guess, args=(Mx_data, My_data))

             # Extract optimized parameters and round off to integer values
            a_opt, b_opt, c_opt = result.x
    

            a_opt = np.round(a_opt / (2**-7))
            b_opt = np.round(b_opt / (2**(-1*3)))
            c_opt = np.round(c_opt / (2**(-1*3)))

            obj_val = objective([a_opt * 2 ** -7, b_opt * 2 ** (-1 * 1), c_opt * 2 ** (-1 * 3)], Mx_data, My_data)

            print(i)
            print("Optimized Parameters:")
            print("a:", a_opt)
            print("b:", b_opt)
            print("c:", c_opt)
            print("MRED_values",obj_val)
            
             
            #obj_val = objective([a_opt*2**-7, b_opt*2**(-1*j), c_opt*2**(-1*k)], Mx_data, My_data)
            #obj_val = objective(result.x, Mx_data, My_data)
            #objective_values.append(obj_val)
            #print("Objective Value:", obj_val)
            
            #print()
#num_elements = len(objective_values)
#print("Number of elements in objective_values:", num_elements)
#plt.plot(scaled_c_values, objective_values, marker='o')
#plt.xlabel('Scaled c_opt*2**(-1*k)')
#plt.ylabel('Objective Value')
#plt.title(f'Objective Function vs. Scaled c_opt for j={j}')
#plt.grid(True)
#plt.show()







