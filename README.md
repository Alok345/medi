
```markdown
# 🛍️ Flutter Firebase Inventory Management App

This is a simple and clean Inventory/Product Management Flutter app built with **Firebase** for backend services like **Authentication** and **Firestore** for database. The app includes features like Google Sign-In, category management, product addition, and user-specific access.

---

## ✨ Features

### 🔐 Authentication
- Google Sign-In using Firebase Auth
- Anonymous login support
- Logout support with state reset

### 📦 Product Management
- Add product with:
  - Category selection
  - Product name, quantity, price, color, size
- Products are saved in Firestore under the `products` collection
- Timestamp (`createdAt`) is stored for sorting/filtering

### 🗂️ Category Management
- Add new categories with:
  - Name
  - Unit (e.g., Kg, Liter, Pcs)
  - Image URL (optional)
- Categories stored in Firestore under `type -> category` document
- Categories used dynamically in product form dropdown

### 🎨 UI Features
- Dropdown for selecting category
- Form fields with validation and status messages
- Top-right menu (3-dot) with:
  - Logged-in user’s display name or email
  - Navigation to Add Product / Add Category
  - Logout option

---

## 🛠️ Tech Stack

| Tech          | Usage                                 |
|---------------|----------------------------------------|
| Flutter       | UI Development                         |
| Firebase Auth | Google & Anonymous Sign-In             |
| Firestore     | Cloud-based Realtime NoSQL database    |
| Google Sign-In| OAuth-based Sign-In Integration        |

---

## 📂 Folder Structure

```
lib/
├── addproduct.dart       # Add Product screen

├── addcategory.dart      # Add Category screen

├── login_page.dart       # Login with Google or Anonymous

├── main.dart             # App entry point
```

---

## 🚀 Getting Started

### 1. Firebase Setup
- Create a Firebase project
- Enable **Authentication** (Google and Anonymous)
- Set up **Firestore**
- Download `google-services.json` and place it in `android/app/`

### 2. Run the App

```bash
flutter pub get
flutter run
```

---

## ✅ Future Enhancements

- Product listing and editing
- Category-wise filtering
- Admin role support
- Image upload to Firebase Storage

---

## 👤 Author

Developed by Alok Kumar  
📧 akumar.panday31@gmail.com

