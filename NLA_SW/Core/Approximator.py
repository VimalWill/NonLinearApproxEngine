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
    def __init__(self, model : keras.Model, Data, config):

        self.model = model 
        self.data  = Data

        self.config = config
    
    def __approximate(self):

        activationTable = {
            "selu"    : TaylorSELU, 
            "swish"   : TaylorSwish, 
            "tanh"    : TaylorTanh, 
            "gelu"    : TaylorGeLu
        }

        approximationPerLayer = []

        _,baseline_accuracy = self.model.evaluate(self.data)
        for LayerID, Layer in enumerate(self.model.layers):
            if (hasattr(Layer, "activation") and Layer.activation.__name__ in activationTable):
                
                for ApproxAmount in range(self.config["max_term"], 3, -1):
                    clonedModel = keras.models.clone_model(self.model) #clone entire model for every iter
                    clonedModel.compile(optimizer=self.config["optimizer"], loss=self.config["loss"])

                    clonedModel.layers[LayerID].activation = keras.activations(activationTable[Layer.activation.__name__](ApproxAmount))
                    _, accuracy = clonedModel.evaluate(self.data)
                    deviation = accuracy - baseline_accuracy
                    if deviation >= 0.02 and deviation <= -0.02:
                        break 
                approximationPerLayer.append({"Layer_ID" : LayerID,
                                              "Layer_Name" : Layer.activation.__name__,
                                              "Approximation_Amount" : ApproxAmount})
                print(f"{LayerID} :  {Layer.activation.__name__} is approximated....")
        return approximationPerLayer

                    
    def compute(self):
        ApproximationPerLayer = self.__approximate()
        return ApproximationPerLayer



                    

                    


