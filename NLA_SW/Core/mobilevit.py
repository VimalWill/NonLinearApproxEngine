import keras
import numpy as np 

try:
    from Approximator import GPNAE
except:
    ImportError

def main():
    mobilevit = keras.models.load_model("models/mobileVit.keras")
    
    #TODO: fetch data and process

    
    EstimatedApproximation = GPNAE(mobilevit).compute()
    print(EstimatedApproximation)

if __name__ == "__main__":
    main()

