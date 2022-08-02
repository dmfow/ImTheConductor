################################################
# Start
print("Ok, lets go")
print("Importing some libraries")


# Flask
from flask import Flask, request
from werkzeug.datastructures import ImmutableMultiDict

# Mixed
from PIL import Image
import os
import base64
import json
import io

# Item prediction
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.applications import imagenet_utils
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.preprocessing.image import load_img
import numpy as np
import cv2

# Dog prediction
from keras.models import Sequential
from keras.layers import GlobalAveragePooling2D, Dense
from keras.applications.vgg16 import VGG16, preprocess_input

from glob import glob


print("Doing some modeling job")


########## Initialize some variables ###################
#
basedir = './'
dog_breed_classes = 133
inputShape = (224, 224)
local_weights_file_vgg16 = basedir + 'modelWeights/vgg16_weights_tf_dim_ordering_tf_kernels_notop.h5'
face_cascade = cv2.CascadeClassifier(basedir+'haarcascades/haarcascade_frontalface_alt.xml')
#
################################################


###### Define a model for Item detection ######
#
MODELS = {
	"resnet": ResNet50
}
modelname = 'resnet'

Network = MODELS[modelname]
model = Network(weights="imagenet")

Network_resnet = ResNet50

model = []
model.append(Network_resnet(weights="imagenet"))

preprocess = imagenet_utils.preprocess_input
#
################################################


########## Dog predictions model handling ###########
#

# Load features
bottleneck_features = np.load(basedir+'bt_features/dogVgg16.npz')
train_VGG16 = bottleneck_features['train']

# Recreate the model
VGG16_model = Sequential()
VGG16_model.add(GlobalAveragePooling2D(input_shape=train_VGG16.shape[1:]))
VGG16_model.add(Dense(dog_breed_classes, activation='softmax'))
VGG16_model.summary()

# Load model
VGG16_model.load_weights('savedModelDogBreed2.weights.best.VGG16.hdf5')

# load list of dog names
dog_names = [item[20:-1] for item in sorted(glob(basedir+"dogImages/valid/*/"))]

#
################################################


################################################
# Start the Flask server
app = Flask(__name__)
#
################################################


########## Dog predictions functions ###########
#

def VGG16_predict_breed(tens):
    bottleneck_feature = extract_VGG16(tens)
    predicted_vector = VGG16_model.predict(bottleneck_feature)
    print("")
    print("--- Dog prediction (VGG16) ---")
    print("1. ",dog_names[np.argmax(predicted_vector)])
    print("2. ",dog_names[np.argsort(np.max(predicted_vector, axis=0))[-2]])
    print("3. ",dog_names[np.argsort(np.max(predicted_vector, axis=0))[-3]])
    print("4. ",dog_names[np.argsort(np.max(predicted_vector, axis=0))[-4]])
    print("5. ",dog_names[np.argsort(np.max(predicted_vector, axis=0))[-5]])
    print("")
    dg = dog_names[np.argmax(predicted_vector)]
    dg = dg[dg.find('.')+1:]
    return dg

def extract_VGG16(tensor):
    model1 = VGG16(weights='imagenet', include_top=False)
    #model1 = VGG16(weights=None, include_top=False)
    #model1.load_weights(local_weights_file_vgg16)
    return model1.predict(preprocess_input(tensor))

#
################################################


########## various functions ###########
#

def decode64_img(msg):
    msg = base64.b64decode(msg)
    buf = io.BytesIO(msg)
    img = Image.open(buf)
    return img


def firstIsVowels(string):
	string = string.lower()
	for char in string:
		if char in "aeiouAEIOU":
			return True
		return False
    
def nicer(string):
	return string.replace("_"," ")

#
################################################


@app.route("/")
def index():
    return json.dumps([{
        'id': 5,
        'name': '<html><body> Hi there </body></html>'
    }])
    

@app.route("/POST/", methods=['POST'])
def upload_image():

	if 'file' in request.form:
		print('')
		print('')
		print('---------------------- New prediction ----------------------------')
		
		image = request.form['file']

		if image:
			
			################ This can be removed. #############
			# Only to show that the sent picture is correctly hadled on the server side and can be saved and opened
			#
			
			myImage = base64.b64decode(image)
			
			# Save image
			with open('image.jpg', 'wb') as fh:
				fh.write(base64.b64decode(image))
						
			# Open the image and resize
			pImg = Image.open('image.jpg')			
			targetHeight = 200
			sizeit = targetHeight/pImg.size[1]
			pImg = pImg.resize((int(pImg.size[0]*sizeit),int(pImg.size[1]*sizeit)))
			
			# Opens the picture for a view
			pImg.show()

			#
			################## Ta bort hit ###########
			
			
			##########################################
			# Prediction
			
			# Base64 decode
			img = decode64_img(image)
			img = img.resize(inputShape)

			# Convert open_cv format for person detection
			open_cv_image = np.array(img) 
			# Convert RGB to BGR 
			open_cv_image = open_cv_image[:, :, ::-1].copy() 

			# Preprocess the image
			image1 = img_to_array(img)
			image2 = np.expand_dims(image1, axis=0)
			image = preprocess(image2)


			for mod in model:
				out = ""
				preds = mod.predict(image)
				
				# Dog check
				itemId = np.argmax(preds)
				if itemId >= 151 and itemId <= 268:
					# It's a dog in the picture
					print("It's a dog in the picture")
					out = out + "I guess there's a dog in the picture\n"
				else:
					print("Dog pictures are cuter")
					out = out + "Get me a dog picture please!\n"

				# Person check
				gray = cv2.cvtColor(open_cv_image, cv2.COLOR_BGR2GRAY)
				faces = face_cascade.detectMultiScale(gray)
				if len(faces) > 0:
					# It's a person in the picture
					if len(faces) > 1:
						print("There are persons in the picture.")
						out = out + "There are persons in the picture. I wonder who it is. \n"
					else:
						print("It's a person in the picture.")
						out = out + "It's a person in the picture. I wonder who it is. \n"
				else:
					print("Can't find any person")


				# Decode the prediction to items
				P = imagenet_utils.decode_predictions(preds)

				# Print locally on the server the best 5 predictions
				print("")
				print("--- Item prediction (Resnet) ---")
				thing = ""
				for (i, (imagenetID, label, prob)) in enumerate(P[0]):
					print("{}. {}: {:.2f}%".format(i + 1, label, prob * 100))
					# Save the best prediction in a variable that will be sent to the client
					if i == 0:
						thing = label
				print("")

				# Dog breed prediction
				dog_breed = VGG16_predict_breed(image2)

				# Make some if's to decide what text should be sent to the client
				if len(dog_breed) > 0:
					
					# Decide on the first text
					s = ''
					if itemId >= 151 and itemId <= 268:					# Dog
						s = "This is probably "
					elif len(faces) > 0:								# Person
						s = "You know this look like "
					else:												# Nor dog nor person
						if firstIsVowels(thing):
							prep = 'an'
						else:
							prep = 'a'
						s = "This is probably " + prep + " {}".format(thing) + "\n" + "If it was a dog it would be "
						
					# Decide on the dog text
					if firstIsVowels(dog_breed):
						prep = 'an'
					else:
						prep = 'a'
					out = out + s + prep+" "+nicer(dog_breed)+"\n"					

				break
			#
			############################################


			return json.dumps([{
				'id': 7,
				'name': out
			}])

	else:
		print("Can not find 'file' in the POST request")
		return json.dumps([{
			'id': 0,
			'name': 'The picture was not sent to the server in a proper way'
		}])

# Enable https with ssl_context='adhoc'
if __name__ == '__main__':
	app.run(port=5000, debug=True, use_reloader=False, ssl_context='adhoc')

