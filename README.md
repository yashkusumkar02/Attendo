# 📝 Attendo - AI-Based Attendance Management System

**Attendo** is a smart AI-powered **Attendance Management System** that automates student attendance using **Face Recognition, Location Verification, and Class Code Authentication**. Designed for **Teachers** and **Students**, it eliminates manual roll calls, ensuring security, accuracy, and efficiency.

---

## 🚀 Features

### **👨‍🏫 Teacher Features**
- **📌 Create an Account** - Sign up with email, name, and college details.
- **🏫 Create Classroom** - Add a classroom with branch, semester, and year.
- **📍 Create Class** - Set location, generate a class code for student verification.
- **✅ Manage Attendance** - Mark, remove, and monitor attendance.
- **📊 View Attendance** - Check student presence and individual records.
- **🔐 Secure Login** - Authenticate with Firebase.

### **👩‍🎓 Student Features**
- **📝 Register & Sign In** - Sign up with personal and academic details.
- **🎭 Face Recognition** - Verify identity using AI-powered face scan.
- **📍 Location Verification** - Ensure attendance is marked within the class radius.
- **🔢 Class Code Entry** - Enter a unique teacher-generated code.
- **📊 Attendance Tracking** - View attendance history and percentages.

---

## 🏗️ Tech Stack

| Tech | Usage |
|------|-------|
| **Flutter** | UI Framework for Android & iOS |
| **Firebase** | Authentication & Firestore Database |
| **GetX** | State Management & Routing |
| **Camera API** | Face Recognition Implementation |
| **Google Fonts** | Custom UI Typography |
| **GeoLocator** | Location-Based Attendance Verification |

---

## 📂 Folder Structure

```
Attendo/
│── android/           # Android-specific code
│── ios/               # iOS-specific code
│── lib/               # Main Flutter project
│   │── controllers/   # GetX Controllers
│   │── models/        # Data Models
│   │── routes/        # Navigation Routes
│   │── screens/       # UI Screens
│   │── utils/         # Helper Functions
│── assets/            # Images & Resources
│── pubspec.yaml       # Dependencies & Configurations
│── README.md          # Project Documentation
```

---

## 🎯 Installation & Setup

### 🔹 **1. Clone the Repository**
```sh
git clone https://github.com/yourusername/attendo.git
cd attendo
```

### 🔹 **2. Install Dependencies**
```sh
flutter pub get
```

### 🔹 **3. Setup Firebase**
- Go to **Firebase Console** → Create Project
- Enable **Authentication** and **Cloud Firestore**
- Download the **google-services.json** (Android) and **GoogleService-Info.plist** (iOS)
- Place them in:
  ```
  android/app/google-services.json
  ios/Runner/GoogleService-Info.plist
  ```

### 🔹 **4. Run the App**
```sh
flutter run
```

---

## 📸 UI

![Attendo UI](https://github.com/user-attachments/assets/a17a495c-9d4e-42d3-903b-63143fda64be)



---

## 🤝 Contributing
Contributions are welcome! To contribute:
1. **Fork the repo**
2. **Create a feature branch** (`feature/new-feature`)
3. **Commit changes** (`git commit -m "Added new feature"`)
4. **Push to branch** (`git push origin feature/new-feature`)
5. **Create a Pull Request**

---

## 🔒 License
This project is **MIT Licensed**. See the [LICENSE](LICENSE) file for details.

---

## 📬 Contact
For queries and support:
- **Email:** kusumkarsuyash1234@gmail.com
- **GitHub:** [yashkusumkar02](https://github.com/yashkusumkar02)
- **LinkedIn:** [suyash-kusumkar](https://linkedin.com/in/suyash-kusumkar)

---

🚀 **Attendo - Making Attendance Smart & Secure!**
