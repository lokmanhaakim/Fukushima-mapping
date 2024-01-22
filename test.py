import cv2
from cvzone.HandTrackingModule import HandDetector
from cvzone.ClassificationModule import Classifier
import numpy as np
import math
import tensorflow
import time

letter = ""
alphabet = ['U','O','Y']

cap = cv2.VideoCapture(0)
detector = HandDetector(maxHands=1)
classfier = Classifier("Imagemodel/keras_model.h5","Imagemodel/labels.txt")
offset = 20
imgSize = 300
folder = "Data/Y"
counter = 0

labels = {'O','U','Y'}


while True:
    success, img = cap.read()
    hands, img = detector.findHands(img)
    if hands:
        hand = hands[0]
        x, y, w, h = hand['bbox']
        imgWhite = np.ones((imgSize, imgSize, 3), np.uint8) * 255

        imgCrop = img[y - offset: y + h + offset, x:x + w + offset]
        imgCropShape = imgCrop.shape
        # cv2.imshow("ImageCrop", imgCrop)

        aspectRatio = h / w

        if aspectRatio > 1:
            k = imgSize / h
            wCal = math.ceil(k*w)
            imgResize = cv2.resize(imgCrop, (wCal, imgSize))
            imgResizeShape = imgResize.shape
            wGap = math.ceil((imgSize - wCal)/2)
            imgWhite[:, wGap:wCal+wGap] = imgResize
            prediction, index = Classifier.getPrediction(imgWhite)
            print(prediction,index)
            time.sleep(2)
            for i in range (0,len(prediction)):
                if (prediction[i]> 0.98) :
                    letter += alphabet[index]
            print(letter)
        else:
            k = imgSize / w
            hCal = math.ceil(k * h)
            imgResize = cv2.resize(imgCrop, (imgSize,hCal))
            imgResizeShape = imgResize.shape
            hGap = math.ceil((imgSize- hCal) / 2)
            imgWhite[hGap:hCal + hGap, :] = imgResize
            # prediction, index = Classifier.getPrediction(imgWhite, draw=False)
        # cv2.rectangle(imgOutput, (x - offset, y - offset - 50),(x - offset + 90, y - offset - 50 + 50), (255, 0, 255), cv2.FILLED)
        # cv2.putText(imgOutput, labels[index], (x, y - 26), cv2.FONT_HERSHEY_COMPLEX, 1.7, (255, 255, 255), 2)
        # cv2.rectangle(imgOutput, (x - offset, y - offset),(x + w + offset, y + h + offset), (255, 0, 255), 4)

        # cv2.imshow("ImageCrop", imgCrop)
        cv2.imshow("ImageWhite2", imgWhite)


    cv2.imshow("Image", img)
    cv2.waitKey(1)

    # if key == ord("e"):
    #     print(letter)
    #     break



    # if key == ord("e"):
    #     break

        # import os
        # root_path = r'C:\Users\USER\PycharmProjects\pythonProject\Data'
        #
        # list = ['O','P','Q','R','S','T','U','V','W','X','Y','Z']
        #
        # for items in list:
        #     path = os.path.join(root_path, items)
        #     os.mkdir(path)