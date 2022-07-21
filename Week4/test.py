from flask import Flask, request
# from flask_restful import reqparse
from PIL import Image
import os
import base64
#from flask import Flask, render_template, request, redirect, url_for

# pip3 install flask_restful
# pip3 install pillow


from werkzeug.datastructures import ImmutableMultiDict
from PIL import Image
import json

app = Flask(__name__)

@app.route("/")
def index():
#	return "This is it"
    return json.dumps([{
        'id': 5,
        'name': 'ihor',
        'age': 5
    }])
    
# Get the uploaded files
@app.route("/POSTIT/", methods=['POST'])
def uploadFiles():
      print("-------------- Im here")
      print(request.form)
      print("--------------")
      # get the uploaded file
      uploaded_file = request.files['filename']
      print(uploaded_file)
      print("Im here again")
      if uploaded_file.filename != '':
           file_path = os.path.join(app.config['UPLOAD_FOLDER'], uploaded_file.filename)
          # set the file path
           uploaded_file.save(file_path)
          # save the file
#      return redirect(url_for('index'))
      return json.dumps([{
           'id': 5,
           'name': 'ihor',
           'age': 5
      }])


@app.route("/POST/", methods=['POST'])
def upload_image():
	#print("-------------- Im here")
	#data2 = dict(request.form)
	#print (data2)
	#print("-------------- Requet files")
	#print(request.files)
	#print("--------------")


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

			return json.dumps([{
				'id': 7,
				'name': 'an image',
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

