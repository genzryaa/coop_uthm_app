# COOP UTHM Store — Mobile E-Commerce & Inventory System

**Course:** BIM 30603 Mobile Application Development  
**Institution:** Universiti Tun Hussein Onn Malaysia (UTHM)  

A full-stack, multi-role Flutter mobile e-commerce application built for **Koperasi UTHM Berhad (Retail Mart)**. The app enables UTHM students and staff to browse retail products, manage a shopping cart, and complete simulated checkout payments, while providing COOP UTHM staff with real-time inventory control, order pickup verification, and financial tracking.

> **Scope Note:** This application strictly covers **COOP UTHM Retail Mart** items (40 SKUs across *Snacks*, *Beverages*, *Stationery*, and *Essentials*). F&B / Secangkir Cafe operations are excluded.

---

## Key Features

### Role-Based Authentication & Routing
* **Firebase Authentication:** Secure email and password sign-up and sign-in.
* **Automatic Role Routing:** Users are authenticated via Firebase Auth and routed based on their `role` field in Cloud Firestore (`buyer` vs. `staff`).

### Student / Buyer Experience (7 Screens)
* **Login & Buyer Registration:** Account creation linked to UTHM Matric/Staff IDs.
* **Retail Catalog:** Browse 40 retail items across 4 categories with live stock counts.
* **Search & Filter:** Instant keyword and category filtering across the Coop inventory.
* **Product Details:** Item pricing, real-time stock availability, and campus self-pickup details.
* **Cart & Stripe Sandbox Checkout:** Quantity adjustments, live subtotal calculation, and simulated Stripe test card payment (`4242 •••• •••• 4242`) that automatically deducts stock in Firestore.
* **Profile & Digital Receipts:** View completed order history and pickup status (`PAID` / `PICKED UP`).

### COOP Staff / Admin Portal (3 Screens)
* **Financial & Operations Dashboard:** Real-time calculation of **Total Revenue**, **Operational Expenses**, and **Net Profit/Loss**, plus automated **Low-Stock Alerts** (`stock <= 5`) with one-tap restocking (`+20 Stock`) and an expense logger.
* **Inventory Manager (CRUD):** Add new retail SKUs, restock existing items (`+10`), or delete discontinued items with instant cloud sync.
* **Sales & Pickup Ledger:** View all customer orders in real time and verify in-store order collection (`Verify Pickup` → `Completed`).

---

## Tech Stack & Architecture

* **Frontend:** Flutter (Material 3)
* **Backend & Database:** Firebase Authentication & Cloud Firestore (Real-time streams + auto-seeding of 40 default retail items)
* **Payment Simulation:** Stripe Sandbox Checkout Flow

### Project Structure
```text
lib/
├── main.dart                     # App entry point & Firebase initialization
├── firebase_options.dart         # Auto-generated FlutterFire configuration
├── data/
│   └── coop_data.dart            # Models (Product, Order, Expense) & Firestore state sync
├── widgets/
│   └── product_card.dart         # Reusable retail product grid card
└── pages/
    ├── login_page.dart           # Multi-role Firebase Auth login
    ├── register_page.dart        # Buyer registration (creates Firestore user profile)
    ├── main_shell.dart           # Buyer bottom navigation shell
    ├── home_page.dart            # Category-filtered retail catalog
    ├── search_page.dart          # Real-time inventory search
    ├── product_detail_page.dart  # Single product view & add-to-cart
    ├── cart_page.dart            # Cart management & Stripe Sandbox checkout
    ├── profile_page.dart         # User profile & completed order receipts
    ├── admin_shell.dart          # Staff/Admin bottom navigation shell
    ├── admin_dashboard_page.dart # Revenue/Expense analytics, low-stock alerts & expense log
    ├── admin_inventory_page.dart # Add, restock, and delete retail SKUs
    └── admin_sales_page.dart     # Live order ledger & pickup verification
