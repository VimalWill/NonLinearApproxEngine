import os 
os.environ["KERAS_BACKEND"] = "tensorflow"

import keras
import json
import numpy as np 
import tensorflow as tf
import tensorflow_datasets as tfds
tfds.disable_progress_bar()

try:
    from Approximator import GPNAE
    print("imported approximation engine")
except:
    ImportError

patch_size = 4  
image_size = 256
expansion_factor = 2 
batch_size = 64
auto = tf.data.AUTOTUNE
resize_bigger = 280
num_classes = 5

#copied from keras
def preprocess_dataset(is_training=True):
    def _pp(image, label):
        if is_training:
            # Resize to a bigger spatial resolution and take the random
            # crops.
            image = tf.image.resize(image, (resize_bigger, resize_bigger))
            image = tf.image.random_crop(image, (image_size, image_size, 3))
            image = tf.image.random_flip_left_right(image)
        else:
            image = tf.image.resize(image, (image_size, image_size))
        label = tf.one_hot(label, depth=num_classes)
        return image, label

    return _pp

def prepare_dataset(dataset, is_training=True):
    if is_training:
        dataset = dataset.shuffle(batch_size * 10)
    dataset = dataset.map(preprocess_dataset(is_training), num_parallel_calls=auto)
    return dataset.batch(batch_size).prefetch(auto)

def main():
    mobilevit = keras.models.load_model("models/mobileVit.keras")
    
    #TODO: fetch data and process
    train_dataset, val_dataset = tfds.load(
    "tf_flowers", split=["train[:90%]", "train[90%:]"], as_supervised=True )
    val_dataset = prepare_dataset(val_dataset, is_training=False)

    desp = open("../NonLinearApproxEngine/configs/mobilevit.json")
    configuration = json.load(desp)

    EstimatedApproximation = GPNAE(mobilevit, val_dataset, config=configuration).compute()
    print(EstimatedApproximation)

if __name__ == "__main__":
    main()

