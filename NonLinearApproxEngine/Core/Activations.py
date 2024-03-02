import tensorflow as tf
import numpy as np
from math import factorial

#custom tensorflow layer for taylor series based selu
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

#custom tensorflow layer for taylor series based TanH
class TaylorTanh(tf.keras.layers.Layer):
    def __init__(self, num_terms):
        super(TaylorTanh, self).__init__()
        self.num_terms = num_terms

    def compute_terms(self, x):
        terms = tf.constant(0.0, dtype=tf.float32)
        for n in range(self.num_terms):
            term = ((-1) ** n) * (x ** (2 * n + 1)) / factorial(2 * n + 1)
            terms += term
        return terms

    def custom_tanh(self, x):
        x = tf.cast(x, tf.float32)
        terms = self.compute_terms(x)
        return terms

    def call(self, inputs):
        return self.custom_tanh(inputs)
