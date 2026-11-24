# COOP UTHM Mobile App

A Flutter-based e-commerce mobile application designed for **Koperasi UTHM Berhad (Retail Store)**. The app provides students and campus staff with a streamlined mobile catalog to browse retail products—including snacks, packaged beverages, stationery, and daily essentials—and complete cashless self-checkout.

---

## Application Pages & Features

### 1. Login Page (`lib/pages/login_page.dart`)
* Authenticates buyers using their UTHM email or matric/staff ID and password.
* Provides navigation to account registration or directly into the main store interface.

### 2. Registration Page (`lib/pages/register_page.dart`)
* Allows new users to register an account by entering their full name, matric/staff ID, UTHM email, and password.

### 3. Main Navigation Shell (`lib/pages/main_shell.dart`)
* Hosts a 4-tab Material Design 3 bottom navigation bar (**Catalog**, **Search**, **Cart**, and **Orders**) for quick switching between core sections.
* Displays a live notification badge on the Cart icon showing the total number of added items.

### 4. Home & Category Catalog (`lib/pages/home_page.dart`)
* Displays the complete retail product grid organized by category chips (**All**, **Snacks**, **Beverages**, **Stationery**, and **Essentials**), with 10 retail items per category.
* Supports quick one-tap addition to the shopping cart directly from each product card.

### 5. Search & Inventory Filter (`lib/pages/search_page.dart`)
* Enables real-time keyword filtering across all Coop retail items by product name or category.

### 6. Product Details Page (`lib/pages/product_detail_page.dart`)
* Displays detailed information for a selected item, including its category badge, price in MYR (RM), real-time available stock count, store pickup details, and an **Add to Cart** button.

### 7. Shopping Cart & Stripe Sandbox Checkout (`lib/pages/cart_page.dart`)
* Lists selected items with increment (`+`) and decrement (`-`) quantity controls and automatically calculates the total payable amount.
* Integrates a **Stripe Sandbox** test card checkout sheet (`4242 •••• •••• 4242`) that processes mock payments, deducts purchased stock quantities, and generates an instant order confirmation receipt.

### 8. Profile & Order History (`lib/pages/profile_page.dart`)
* Displays the active user's profile details, a chronological list of paid order receipts, and a logout button.

---

## Project Structure

```text
lib/
├── main.dart                     # App entry point and Material 3 theme
├── data/
│   └── coop_data.dart            # Product, Cart, and Order models + store state
├── widgets/
│   └── product_card.dart         # Reusable product grid card widget
└── pages/
    ├── login_page.dart           # User login screen
    ├── register_page.dart        # User registration screen
    ├── main_shell.dart           # Bottom navigation bar wrapper
    ├── home_page.dart            # Category catalog screen
    ├── search_page.dart          # Product search screen
    ├── product_detail_page.dart  # Item detail screen
    ├── cart_page.dart            # Cart and Stripe checkout screen
    └── profile_page.dart         # User profile and order receipts screen
