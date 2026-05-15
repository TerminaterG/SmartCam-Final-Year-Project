from flask import Flask, Response, jsonify
import cv2
import threading
import time
import json
from ultralytics import YOLO

app = Flask(__name__)

# 🔁 ESP32 STREAM
ESP_STREAM_URL = "http://10.193.189.62:81/stream"

# 🧠 LOAD YOLO
model = YOLO("yolov8n.pt")

# 🧠 LOAD FACE MODEL
recognizer = cv2.face.LBPHFaceRecognizer_create()
recognizer.read("face_model.yml")

with open("face_labels.json", "r") as f:
    label_map = {int(k): v for k, v in json.load(f).items()}

face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

status = "starting..."
frame_lock = threading.Lock()
last_frame = None


# ================= STREAM PROCESS =================
def process_stream():
    global last_frame, status

    cap = cv2.VideoCapture(ESP_STREAM_URL)

    while True:
        ret, frame = cap.read()

        if not ret:
            print("Reconnecting to ESP32...")
            cap.release()
            time.sleep(1)
            cap = cv2.VideoCapture(ESP_STREAM_URL)
            continue

        frame = cv2.resize(frame, (640, 480))
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        face_name = "UNKNOWN"
        face_found = False

        # 🔍 FACE DETECTION
        faces = face_cascade.detectMultiScale(gray, 1.1, 5)

        for (x, y, w, h) in faces:
            face_found = True
            face_img = cv2.resize(gray[y:y+h, x:x+w], (200, 200))

            id_, conf = recognizer.predict(face_img)

            if conf < 100:   # 🔥 tighter threshold (better accuracy)
                face_name = label_map.get(id_, "KND")
                color = (0, 255, 0)
            else:
                face_name = "UNKNOWN"
                color = (0, 0, 255)

            cv2.rectangle(frame, (x, y), (x+w, y+h), color, 2)
            cv2.putText(frame, face_name, (x, y-10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 2)

        # 🔹 YOLO DETECTION
        detected = []

        # 🔥 Lower confidence for better detection
        results = model(frame, conf=0.25, verbose=False)

        for r in results:
            for box in r.boxes:
                cls = int(box.cls[0])
                label = model.names[cls]

                # ❌ skip person
                if label == "person":
                    continue

                detected.append(label)

                x1, y1, x2, y2 = map(int, box.xyxy[0])

                cv2.rectangle(frame, (x1, y1), (x2, y2), (255, 0, 0), 2)
                cv2.putText(frame, label, (x1, y1-10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 0, 0), 2)

        # 🔥 DANGER OBJECT LIST
        danger_objects = ["knife", "scissors"]

        # 🔥 DECISION LOGIC (IMPROVED)
        if any(obj in detected for obj in danger_objects):
            status = "DANGER 🚨"

        elif face_found and face_name == "KND":
            status = "SAFE (KND)"

        elif face_found:
            status = "UNKNOWN PERSON ALERT 🚨"

        else:
            status = "SAFE"

        # 🔹 SHOW STATUS
        cv2.putText(frame, f"STATUS: {status}", (20, 40),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)

        # 🔄 UPDATE FRAME
        with frame_lock:
            last_frame = frame.copy()


# ================= VIDEO STREAM =================
@app.route("/video_feed")
def video_feed():
    def generate():
        while True:
            with frame_lock:
                if last_frame is None:
                    continue
                _, buffer = cv2.imencode('.jpg', last_frame)
                frame_bytes = buffer.tobytes()

            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

    return Response(generate(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


# ================= STATUS =================
@app.route("/status")
def get_status():
    return jsonify({"status": status})


@app.route("/snapshot")
def snapshot():
    global last_frame
    with frame_lock:
        if last_frame is None:
            return "No frame", 404

        _, buffer = cv2.imencode('.jpg', last_frame)
        return Response(buffer.tobytes(), mimetype='image/jpeg')


# ================= HOME =================
@app.route("/")
def home():
    return "AI Surveillance Server Running 🚀"


# ================= MAIN =================
if __name__ == "__main__":
    threading.Thread(target=process_stream, daemon=True).start()
    app.run(host='0.0.0.0', port=5000)