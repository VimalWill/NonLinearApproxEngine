import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 

from tensorflow import keras
from tabulate import tabulate
from NonLinearApproxEngine.Core.Activations import TaylorSELU, TaylorTanh

_activationTable = {
    "selu": TaylorSELU,
    "tanh": TaylorTanh
}

class ApproxEngine:
    def __init__(self, model: keras.Model):
        self.model = model 
    
    def _readModel(self):
        _modelData = []
        _tabulation_data = [["Layer ID", "Activation Name"]]
        for _id, _layer in enumerate(self.model.layers):
            if hasattr(_layer, "activation") and (_layer.activation.__name__ in _activationTable):
                _modelData.append({"layer_id": _id, "activation": _layer.activation.__name__})
                _tabulation_data.append([_id, _layer.activation.__name__])
        
        print(tabulate(_tabulation_data, headers='firstrow', tablefmt='grid'))
        return _modelData

class ModelReconstruct(ApproxEngine):
    def __init__(self, model: keras.Model):
        super(ModelReconstruct, self).__init__(model)
        self.model = model 
        self.cfg = self._readModel()
    
    def nonLinearApproximation(self):
        num_layers = len(self.model.layers)
        for config in self.cfg:
            m_layer = self.model.layers[config["layer_id"]]

            if config["layer_id"] < int(0.2 * num_layers):
                m_layer.activation = _activationTable[m_layer.activation.__name__](num_terms=10)

            elif int(0.2 * num_layers) < config["layer_id"] < int(0.7 * num_layers):
                m_layer.activation = _activationTable[m_layer.activation.__name__](num_terms=6)

            else:
                m_layer.activation = _activationTable[m_layer.activation.__name__](num_terms=4)

        print("---------- approximation completed --------------")
        return self.model
