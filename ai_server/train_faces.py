import cv2
import os
import json
import numpy as np

data_path = "known_faces"
face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

faces = []
labels = []
label_map = {}
current_label = 0

for person_name in os.listdir(data_path):
    person_path = os.path.join(data_path, person_name)

    if not os.path.isdir(person_path):
        continue

    label_map[current_label] = person_name

    for image_name in os.listdir(person_path):
        img_path = os.path.join(person_path, image_name)
        img = cv2.imread(img_path)

        if img is None:
            continue

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        detected_faces = face_cascade.detectMultiScale(
            gray, scaleFactor=1.1, minNeighbors=5
        )

        for (x, y, w, h) in detected_faces:
            face = gray[y:y+h, x:x+w]
            face = cv2.resize(face, (200, 200))

            faces.append(face)
            labels.append(current_label)

    current_label += 1

recognizer = cv2.face.LBPHFaceRecognizer_create()
recognizer.train(faces, np.array(labels))

recognizer.save("face_model.yml")

with open("face_labels.json", "w") as f:
    json.dump(label_map, f)

print("✅ Training complete!")