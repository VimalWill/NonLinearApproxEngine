import tensorflow as tf 
import numpy as np 
import keras 

from Activations import *

class GPNAE:
    def __init__(self, model : keras.Model, Data):
        """
        Class for Generalize approximation for non-linear
        activation functions 

        """
        self.model = model 
        self.data  = Data
    
    def __approximate(model : keras.Model, Data):

        activationTable = {
            "selu"    : TaylorSELU, 
            # "sigmoid" : TaylorSigmoid, 
            "swish"   : TaylorSwish, 
            "tanh"    : TaylorTanh, 
            "gelu"    : TaylorGeLu
        }

        clonedModel = keras.models.clone_model(model)
        for LayerID, Layer in enumerate(clonedModel.layers):
            if (hasattr(Layer, "activation") and Layer.activation.__name__ in activationTable):
                for ApproxAmount in range(10,3,-1):
                    clonedModel.layers[LayerID].activation = activationTable[Layer.activation.__name__](ApproxAmount)
                    _, accuracy = clonedModel.evaluate(Data)
            
    def compute(self):
        ApproximationPerLayer = self.__approximate(self.model, self.data)
        return ApproximationPerLayer


                    

                    


