import tensorflow as tf 
import numpy as np
import math
from math import factorial, sqrt
import keras

class TaylorSELU(tf.keras.layers.Layer):
    def __init__(self, num_terms):
        super(TaylorSELU, self).__init__()
        self.num_terms = num_terms

    @tf.function
    def compute_series(self, x):
        series_result = 0
        for n in range(1, self.num_terms + 1):
            series_result += (x ** n) / factorial(n)
        return series_result

    @tf.function
    def custom_selu(self, x):
        lambda_val = 1.05070098
        alpha_val = 1.67326324
        is_positive = tf.cast(x > 0, tf.float32)  # Indicator for x > 0

        return lambda_val * (is_positive * x) + alpha_val * (1 - is_positive) * self.compute_series(x)

    def call(self, inputs):
        return self.custom_selu(inputs)

class TaylorSigmoid(tf.keras.layers.Layer):
    def __init__(self, num_terms):
        super(TaylorSigmoid, self).__init__()
        self.num_terms = num_terms
    
    @tf.function
    def custom_sigmoid(self,x):
        approx = 0
        for terms in range(self.num_terms + 1):
            approx += (x**terms) / factorial(terms)
        
        return approx / (approx + 1)
    
    def call(self, inputs):
        return self.custom_sigmoid(inputs)

class TaylorSwish(tf.keras.layers.Layer):
    def __init__(self, num_terms):
        super(TaylorSwish, self).__init__()
        self.num_terms = num_terms
    
    @tf.function
    def custom_swish(self, x):
        return x * TaylorSigmoid(self.num_terms)(x)
    
    def call(self, inputs):
        return self.custom_swish(inputs)

class TaylorTanh(tf.keras.layers.Layer):
    def __init__(self, num_terms):
        super(TaylorTanh, self).__init__()
        self.num_terms = num_terms
    
    @tf.function
    def custom_tanh(self,x):
        approx = 0 
        for term in range(self.num_terms + 1):
            approx += ((2*x)**term / factorial(term))
        
        return (approx - 1) / (approx + 1)
    
    def call(self, inputs):
        return self.custom_tanh(inputs)

class TaylorGeLu(tf.keras.layers.Layer):
    def __init__(self, num_terms):
        super(TaylorGeLu, self).__init__()
        self.num_terms = num_terms
    
    def custom_gelu(self,x):
        return x * TaylorSigmoid(self.num_terms)(1.702 * x)
    
    def call(self, inputs):
        return self.custom_gelu(inputs)

def FunctionalityTest():
    import matplotlib.pyplot as plt
    import seaborn as sns
    import numpy as np 
    
    # Set seaborn style
    sns.set_style("whitegrid")
    
    # Generate x values
    x_values = np.linspace(-5, 5, 300)
    
    # Generate y values for the Swish function
    y_values = tf.nn.selu(x_values)
    
    # Generate approximations for different values of n with offsets
    y_approx_25 = TaylorSELU(14)(x_values) - 0.4  # Offset for better visualization
    y_approx_20 = TaylorSELU(10)(x_values) - 0.2  # Offset for better visualization
    y_approx_10 = TaylorSELU(9)(x_values) + 0.2  # Offset for better visualization
    # y_approx_7 = TaylorTanh(7)(x_values) + 0.4  # Offset for better visualization
    
    # Create plot
    plt.figure(figsize=(6.9, 5.2))  # IEEE single column width is 3.5 inches
    
    # Plot Swish function
    plt.plot(x_values, y_values, label='Actual SeLu', color='purple', linewidth=1.5)
    
    # Plot approximations
    plt.plot(x_values, y_approx_25, label='Approximation (n=14)', color='blue', linestyle='--')
    plt.plot(x_values, y_approx_20, label='Approximation (n=10)', color='green', linestyle='-.')
    plt.plot(x_values, y_approx_10, label='Approximation (n=9)', color='red', linestyle=':')
    # plt.plot(x_values, y_approx_7, label='Approximation (n=7)', color='purple', linestyle='-')
    
    # Adjust labels and legend
    plt.xlabel('Input Tensor (x)')
    plt.ylabel('y = SeLu (x)')
    plt.title('SeLu Vs Approximated SeLu')
    plt.legend()
    
    # Save the plot as a PDF
    plt.savefig("SeLu_Approximation.pdf", format='pdf', bbox_inches='tight')
    
    plt.show()

# FunctionalityTest() don't un-comment while execution