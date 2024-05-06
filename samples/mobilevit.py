import keras
import numpy as np 

try:
    from NLA_SW.Core.Approximator import GPNAE
except:
    ImportError

def main():
    mobilevit = keras.models.load_model("models/mobileVit.keras")
    
    #TODO: fetch data and process

    
    EstimatedApproximation = GPNAE(mobilevit)
    print(EstimatedApproximation)

if __name__ == "__main__":
    main()

