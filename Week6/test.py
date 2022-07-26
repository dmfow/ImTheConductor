from flask import Flask, request
from PIL import Image
import os
import base64


from werkzeug.datastructures import ImmutableMultiDict
from PIL import Image
import json
import io


from tensorflow.keras.applications import ResNet50
#from tensorflow.keras.applications import VGG16
#from tensorflow.keras.applications import VGG19
from tensorflow.keras.applications import imagenet_utils
from tensorflow.keras.applications.inception_v3 import preprocess_input
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.preprocessing.image import load_img
import numpy as np
# import argparse
import cv2




app = Flask(__name__)




MODELS = {
#	"vgg16": VGG16,
#	"vgg19": VGG19,
	"resnet": ResNet50
}

inputShape = (224, 224)
preprocess = imagenet_utils.preprocess_input

modelname = 'resnet'
#print(modelname)

Network = MODELS[modelname]
model = Network(weights="imagenet")

#Network_v16 = VGG16
#Network_v19 = VGG19
Network_resnet = ResNet50
#Network_inception = InceptionV3
#Network_xception = Xception # TensorFlow ONLY

model = []
#model.append(Network_v16(weights="imagenet"))
#model.append(Network_v19(weights="imagenet"))
model.append(Network_resnet(weights="imagenet"))



def decode_img(msg):
    msg = base64.b64decode(msg)
    buf = io.BytesIO(msg)
    img = Image.open(buf)
    return img



@app.route("/")
def index():
#	return "This is it"
    return json.dumps([{
        'id': 5,
        'name': 'ihor',
        'age': 5
    }])
    

@app.route("/POST/", methods=['POST'])
def upload_image():

	if 'file' in request.form:
		print('Yes')
		image = request.form['file']

		if image:
			#print("-------------- Image")
			#print(image)
			#print("-------------- Image stop")
			myImage = base64.b64decode(image)
			
			with open('image2.jpg', 'wb') as fh:
				fh.write(myImage)
				
			with open('image.jpg', 'wb') as fh:
				#fh.write(image)
				fh.write(base64.b64decode(image))
				#fh.write(base64.decodebytes(image))
			
			
			#sizeit = 0.1
			pImg = Image.open('image.jpg')			
			targetHeight = 200
			sizeit = targetHeight/pImg.size[1]
			pImg = pImg.resize((int(pImg.size[0]*sizeit),int(pImg.size[1]*sizeit)))
			pImg.show()

			##########################################
			# Prediction

			img = decode_img(image)
			
			#img = 'testimg_troja2_vitBG - Copy.JPG'
			#img = Image.open('image.jpg')			
			
			#img = pImg
			
			#img = img.resize(224,224)
			img = img.resize(inputShape)

			#image = load_img(img, target_size=inputShape)
			#image = img_to_array(image)
			image = img_to_array(img)
			image = np.expand_dims(image, axis=0)
			image = preprocess(image)

			out = "No prediction"
			for mod in model:
				preds = mod.predict(image)
				P = imagenet_utils.decode_predictions(preds)

				# Display the rank-5 predictions 
				for (i, (imagenetID, label, prob)) in enumerate(P[0]):
					print("{}. {}: {:.2f}%".format(i + 1, label, prob * 100))
				print("")

				for (i, (imagenetID, label, prob)) in enumerate(P[0]):
					print("{}. {}: {:.2f}%".format(i + 1, label, prob * 100))
					
					if i == 0:
						out = "{}: {:.2f}%".format(label, prob * 100)

			#
			############################################


			return json.dumps([{
				'id': 7,
				'name': out,
				'age': 7
			}])

	else:
		print('Allowed image types are -> png, jpg, jpeg, gif')
#		return redirect(request.url)
		return json.dumps([{
			'id': 0,
			'name': 'noope',
			'age': 0
		}])

if __name__ == '__main__':
	app.run(port=5000, debug=True, ssl_context='adhoc')

