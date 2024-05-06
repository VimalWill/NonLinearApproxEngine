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



