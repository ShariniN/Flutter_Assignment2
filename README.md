⚡️ Electronics Store App — Flutter + Laravel Backend

Welcome to the Electronics Store App, a full-featured, cross-platform mobile application built with Flutter and powered by a Laravel backend.

This project combines a rich, responsive Flutter frontend with a secure, scalable Laravel REST API, offering a modern, real-world e-commerce experience for electronics shoppers.
It features authentication, offline caching, product filtering, biometric-secured checkout, image-based product reviews, and dynamic tech spec retrieval through an external API.

📱 Overview

This Flutter + Laravel project represents a production-ready e-commerce mobile app tailored for electronics retail.
It demonstrates a multi-layered architecture integrating:

Backend RESTful APIs built with Laravel.

Secure local persistence (SQLite, caches, biometrics).

Rich, device-native features (camera, geolocation).

Real-time external API calls for live product specifications.

It supports both online and offline modes, ensuring users can browse cached data and securely complete purchases even with intermittent connectivity.

🖥️ Frontend (Flutter)

Cross-Platform Compatibility – Built using Flutter, the app runs natively on both Android and iOS with a unified codebase.

Modern, Responsive UI – Carefully designed layouts using Material Design 3, with adaptive widgets that scale across phones and tablets.

Dynamic Home Screen – Displays banners, promotional sliders, and featured categories, with content fetched dynamically from the Laravel backend.

Product Cards & Filters – Interactive product cards show real-time data, while filters allow users to sort and refine by brand, price, or category.

Category Navigation – Structured category views (e.g., Laptops, Smartphones, Smartwatches, etc.) 

Product Detail Pages – Rich product pages featuring pricing, availability, specifications, and user reviews — including live data from an external specs API.

🔐 Authentication & User Management

Laravel Sanctum Authentication – Secure token-based login and registration through Laravel’s API endpoints.

Biometric Authentication – Integrates with the local_auth plugin to allow Face ID / fingerprint verification before performing sensitive actions such as checkout or payment.

User Profile & Orders – Editable user profile, viewable order history, and saved address book synchronized with the backend.

🛍️ Shopping & Checkout Flow

Checkout with Biometrics – Secure checkout experience that requires biometric confirmation before completing a transaction.

Order Summary Screen – Clean UI summarizing items, delivery address, taxes, and total cost.

Delivery Geolocation – Integrated geolocator service to auto-detect the user’s current address or delivery location.

💬 Reviews & Ratings

Local Review Caching (SQLite) – Reviews are stored locally first, then synchronized to the backend when online.

Camera Integration – Users can capture product photos using the camera 

Ratings & Stars – Dynamic rating system linked with the backend to calculate average ratings in real time.

🌐 API Integrations

Laravel REST API – Handles authentication, products, categories, reviews, orders, and cart operations.

External Tech Specs API – Fetches live technical specifications for products (e.g., CPU, GPU, display, battery, etc.) using a vercel.

Caching Layer – Responses from APIs are cached locally using SQLite for faster repeated access and offline continuity.

📦 Offline Functionality

SQLite Database (sqflite) – All critical data such as categories, products, and reviews are stored locally for offline browsing.

Network Awareness – The app intelligently detects connectivity status and updates the UI to reflect online/offline states.

🧠 Performance & Architecture

Repository Pattern – Clear separation of data sources (API, local DB, external API) for scalability and testability.

State Management (Provider) – Efficient app-wide reactive state handling.

Lazy Loading & Pagination – Product grids load incrementally for better performance.

🔒 Security

Biometric Checkout Confirmation – Extra security layer for payment authorization using local_auth.

Secure Storage – Tokens, user data, and cached information encrypted via flutter_secure_storage.

HTTPS Communication – All API requests are made securely over HTTPS using token-based headers.

Laravel Sanctum Tokens – Backend authentication tokens are verified on every request.

CSRF & Input Validation – Laravel backend employs built-in middleware for CSRF protection and sanitization.
