# SmartCam Final Year Project

## Overview

SmartCam is a low-cost intelligent surveillance system developed using ESP32-CAM, Python-based computer vision processing, YOLOv8 object detection, and a Flutter mobile application.

The system provides:

- Real-time video streaming
- Face detection and recognition
- Object detection using YOLOv8
- Mobile monitoring
- Servo motor control
- SAFE / ALERT status indication

This project combines embedded systems, machine learning, and mobile application development for residential security applications.

---

# Repository Structure

```text
SmartCam-Final-Year-Project
│
├── CameraWebServer_final
│   └── ESP32-CAM Arduino code
│
├── ai_server
│   ├── Python AI server
│   ├── YOLO model
│   ├── Flask server
│
├── android
│
├── lib
│
├── SmartCam_App.zip
│
├── pubspec.yaml
│
├── pubspec.lock
│
└── README.md
```

---

# Hardware Requirements

- ESP32-CAM Module
- USB-to-TTL Converter
- Servo Motor
- 5V Power Adapter
- Jumper Wires
- Laptop/Desktop
- Android Mobile Device

---

# Software Requirements

Install the following software before setup:

| Software | Purpose |
|---|---|
| Arduino IDE | Upload ESP32-CAM code |
| Python 3.10+ | Run AI processing server |
| Visual Studio Code | Edit and run Python code |
| Flutter SDK | Run mobile application |
| Android Studio | Flutter and Android support |
| Git | Clone repository |

---

# STEP 1 — Clone Repository

Open Command Prompt or Terminal:

```bash
git clone https://github.com/TerminatorG/SmartCam-Final-Year-Project.git
```

Go into project folder:

```bash
cd SmartCam-Final-Year-Project
```

---

# STEP 2 — Install Arduino IDE

Download Arduino IDE:

https://www.arduino.cc/en/software

Install normally.

---

# STEP 3 — Install ESP32 Board Package

Open Arduino IDE.

Go to:

```text
File → Preferences
```

In “Additional Board Manager URLs” add:

```text
https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
```

Now go to:

```text
Tools → Board → Boards Manager
```

Search:

```text
ESP32
```

Install:

```text
ESP32 by Espressif Systems
```

---

# STEP 4 — Connect ESP32-CAM

Connect USB-to-TTL converter:

| USB-TTL | ESP32-CAM |
|---|---|
| 5V | 5V |
| GND | GND |
| TX | U0R |
| RX | U0T |
| GND | IO0 (ONLY during upload) |

---

# STEP 5 — Upload ESP32-CAM Code

Open:

```text
CameraWebServer_final
```

Select board:

```text
Tools → Board → AI Thinker ESP32-CAM
```

Select correct COM port.

Update Wi-Fi credentials inside code:

```cpp
const char* ssid = "YOUR_WIFI_NAME";
const char* password = "YOUR_WIFI_PASSWORD";
```

Click Upload.

After upload:

1. Disconnect IO0 from GND
2. Press RESET button

Open Serial Monitor.

Copy ESP32-CAM IP address.

Example:

```text
192.168.1.5
```

---

# STEP 6 — Install Python

Download Python:

https://www.python.org/downloads/

IMPORTANT:

Enable:

```text
Add Python to PATH
```

Verify installation:

```bash
python --version
```

---

# STEP 7 — Install Python Libraries

Open terminal inside:

```text
ai_server
```

Run:

```bash
pip install flask
pip install opencv-python
pip install numpy
pip install ultralytics
pip install pillow
pip install requests
pip install cvzone
```

---

# STEP 8 — Configure Python Server

Open Python project in VS Code.

Locate ESP32 stream URL.

Replace with ESP32 IP address:

```python
stream_url = "http://192.168.1.5:81/stream"
```

Save file.

---

# STEP 9 — Run Python Server

Inside ai_server folder run:

```bash
python app.py
```

OR

```bash
python main.py
```

(depending on file name)

Flask server will start.

Example:

```text
Running on:
http://192.168.1.10:5000
```

Keep terminal running.

---

# STEP 10 — Install Flutter

Download Flutter SDK:

https://flutter.dev/docs/get-started/install

Extract Flutter folder.

Add Flutter to PATH.

Verify installation:

```bash
flutter doctor
```

---

# STEP 11 — Install Android Studio

Install Android Studio.

Install:
- Android SDK
- Flutter Plugin
- Dart Plugin

Connect Android device with USB debugging enabled.

OR

Use Android emulator.

---

# STEP 12 — Setup Flutter Application

Open project folder in Android Studio.

Run:

```bash
flutter pub get
```

Locate Flask API URLs.

Replace with Flask server IP:

Example:

```text
http://192.168.1.10:5000
```

Save changes.

---

# STEP 13 — Run Flutter Application

Run:

```bash
flutter run
```

The application will install on connected Android device/emulator.

---

# STEP 14 — Install APK Directly (Optional)

Extract:

```text
SmartCam_App.zip
```

Install APK on Android device.

Allow:
```text
Install from unknown sources
```

if prompted.

---

# STEP 15 — System Operation

1. Power ON ESP32-CAM
2. Ensure:
   - Laptop
   - Mobile device
   - ESP32-CAM

are connected to same Wi-Fi network.

3. Start Python Flask server
4. Open mobile application
5. Verify:
   - Live video feed
   - Face recognition
   - Object detection
   - Servo control
   - SAFE / ALERT status

---

# Features

## Face Recognition
- Detects authorized and unauthorized individuals
- Uses Haar Cascade + LBPH algorithm

## Object Detection
- Uses YOLOv8 model
- Detects predefined objects in real time

## Mobile Monitoring
- Live video streaming
- Real-time status updates
- Servo control

## Servo Motor Control
- Remote camera movement
- Wider surveillance coverage

---

# Troubleshooting

## ESP32-CAM not connecting
- Check Wi-Fi credentials
- Verify power supply
- Press RESET button

## No video stream
- Verify ESP32 IP address
- Open stream URL in browser
- Check firewall settings

## Flask server not starting

Install missing library:

```bash
pip install <library_name>
```

## Mobile app not connecting
- Ensure same Wi-Fi network
- Verify Flask server IP
- Ensure Flask server is running

---

# Known Limitations

- Detection accuracy may reduce under poor lighting conditions
- Occasional false alerts may occur
- Network latency may slightly affect streaming performance

---

# Future Improvements

- Cloud integration
- Push notifications
- Multi-camera support
- Improved AI models
- Remote internet access
- Encrypted communication

---

# Developed By

- KN Dhanush Kumar
- Nallabothula Uday Kiran
- Seelam Pranay Dinakar
- Arpitha

Guide:  
Prof. Sunil M P

Department of Electronics & Communication Engineering  
Jain Deemed-to-be University Bengaluru, India
