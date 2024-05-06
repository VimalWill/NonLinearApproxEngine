import tensorflow as tf 
import numpy as np 
import time
import keras 

from Activations import *

class GPNAE:
    """
    A class for a General Purpose Non-linear Approximation Engine,
    a domain-specific software algorithm for estimating Taylor-series
    based approximations for specified non-linear functions in CNNs/Transformers.

    Parameters:
        model (tf.keras.Model): AI model
        data (tf.Dataset): Validation data

    Returns:
        approximationPerLayer: Approximation required per activation 
        (supports non-linear functions)
    """
    def __init__(self, model : keras.Model, Data):

        self.model = model 
        self.data  = Data
    
    def __approximate(model : keras.Model, Data):

        activationTable = {
            "selu"    : TaylorSELU, 
            "swish"   : TaylorSwish, 
            "tanh"    : TaylorTanh, 
            "gelu"    : TaylorGeLu
        }

        approximationPerLayer = []

        baseline_accuracy = model.evaluate(Data)
        clonedModel = keras.models.clone_model(model)
        for LayerID, Layer in enumerate(clonedModel.layers):
            if (hasattr(Layer, "activation") and Layer.activation.__name__ in activationTable):

                #estimate the amount of approx. per layer 
                for ApproxAmount in range(40,3,-1):
                    clonedModel.layers[LayerID].activation = activationTable[Layer.activation.__name__](ApproxAmount)
                    _, accuracy = clonedModel.evaluate(Data)
                    deviation = (accuracy - baseline_accuracy) * 100
                    if (deviation >=2) or (deviation <= -2):
                        break
                approximationPerLayer.append({"Layer_ID" : LayerID, 
                                              "LayerName" : Layer.activation.__name__,
                                              "AmountOfApproximation" : ApproxAmount})
                
                time.sleep(0.1) #breath time for CPU
        return approximationPerLayer
                    
    def compute(self):
        ApproximationPerLayer = self.__approximate(self.model, self.data)
        return ApproximationPerLayer



                    

                    


