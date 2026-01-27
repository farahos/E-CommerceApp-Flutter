# E-Commerce Flutter App

A complete Flutter e-commerce application with authentication, product browsing, shopping cart, and order management.

## Features

- 🔐 User Authentication (Login, Register, Password Reset)
- 🛍️ Product Browsing (List, Details, Search, Categories)
- 🛒 Shopping Cart Management
- 📦 Order Management (View orders, Order details)
- 👤 User Profile
- 🎨 Modern UI with Material Design 3

## Setup

1. Make sure you have Flutter installed (SDK >=3.0.0)

2. Install dependencies:
```bash
cd frontend
flutter pub get
```

3. Update API base URL in `lib/utils/constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP_ADDRESS:8000/api';
```
For Android emulator, use `http://10.0.2.2:8000/api`
For iOS simulator, use `http://localhost:8000/api`
For physical device, use your computer's IP address

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── category_model.dart
│   ├── cart_model.dart
│   └── order_model.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── category_provider.dart
│   ├── cart_provider.dart
│   └── order_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   ├── home/
│   ├── products/
│   ├── cart/
│   ├── orders/
│   └── profile/
├── services/                 # API services
│   └── api_service.dart
├── utils/                    # Utilities
│   └── constants.dart
└── widgets/                  # Reusable widgets
    ├── product_card.dart
    └── cart_item_widget.dart
```

## Backend API Endpoints

The app connects to the following backend endpoints:

- `/api/user/registerUser` - User registration
- `/api/user/loginUser` - User login
- `/api/products` - Product CRUD operations
- `/api/categories` - Category operations
- `/api/cart` - Cart operations
- `/api/orders` - Order operations
- `/api/forgetpassword` - Password reset

## Dependencies

- `provider` - State management
- `http` - HTTP requests
- `shared_preferences` - Local storage
- `cached_network_image` - Image caching
- `intl` - Date formatting

## Notes

- The backend uses cookie-based authentication
- Make sure your backend server is running on port 8000
- Update the base URL according to your development environment
