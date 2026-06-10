# TaiLieuDuAn.md — Tai Lieu Ky Thuat Chi Tiet Ecommerce Mobile (Flutter)

> Tai lieu nay tong hop toan bo thong tin ky thuat cua du an Ecommerce Mobile (Flutter), bao gom cau truc du an, cong nghe su dung, cac tinh nang, luong hoat dong, API endpoints, trang thai hoan thien, va cac van de can luu y.

---

## Muc Luc

1. [Tong Quan Du An](#1-tong-quan-du-an)
2. [Cau Truc Du An](#2-cau-truc-du-an)
3. [Cong Nghe Su Dung](#3-cong-nghe-su-dung)
4. [Core Infrastructure](#4-core-infrastructure)
5. [Models (Data)](#5-models-data)
6. [Services (API Layer)](#6-services-api-layer)
7. [Providers (State Management)](#7-providers-state-management)
8. [Screens — Public User](#8-screens--public-user)
9. [Screens — Admin Panel](#9-screens--admin-panel)
10. [Widgets](#10-widgets)
11. [Routes](#11-routes)
12. [API Endpoints](#12-api-endpoints)
13. [Trang Thai Hoan Thien Theo Phase](#13-trang-thai-hoan-thien-theo-phase)
14. [Known Issues & Technical Notes](#14-known-issues--technical-notes)
15. [Luong Hoat Dong Chinh](#15-luong-hoat-dong-chinh)
16. [Cac File Chinh Yeu](#16-cac-file-chinh-yeu)

---

## 1. Tong Quan Du An

- **Ten du an:** Ecommerce Mobile
- **Mo ta:** Ung dung di dong thuong mai dien tu (e-commerce) su dung Flutter, di chuyen tu frontend React sang Flutter.
- **Nen tang backend:** Spring Boot (Java) REST API
- **Base URL mac dinh:** `http://localhost:8080` (Android emulator: `http://10.0.2.2:8080`)
- **Ngon ngu:** Dart (Flutter)
- **Flutter SDK:** >= 3.19.0
- **Dart SDK:** >= 3.3.0
- **Trang thai hoan thien:** ~95% (theo README2.md)

---

## 2. Cau Truc Du An

```
ecommerce-Mobile/
├── .env                          # Bien moi truong (API_BASE_URL)
├── .gitignore
├── pubspec.yaml                  # Dependencies Flutter
├── pubspec.lock
├── analysis_options.yaml
├── README.md                     # Tai lieu phat trien chi tiet
├── README2.md                    # Ke hoach test
├── MIGRATION_MASTER.md
├── test/
│   └── widget_test.dart         # Smoke test co ban
├── lib/
│   ├── main.dart                # Entry point
│   ├── app.dart                # MaterialApp root (go_router + theme)
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart           # Dio instance factory
│   │   │   └── api_interceptors.dart     # AuthInterceptor (Bearer token)
│   │   ├── config/
│   │   │   └── api_config.dart          # API endpoint prefixes
│   │   ├── constants/
│   │   │   └── app_colors.dart          # (rong — chua su dung)
│   │   ├── router/
│   │   │   └── app_router.dart          # GoRouter voi auth guard
│   │   ├── theme/
│   │   │   └── app_colors.dart          # Mau sac chinh (su dung chinh)
│   │   └── utils/
│   │       ├── jwt_utils.dart           # Decode JWT payload
│   │       └── order_status.dart       # Enum OrderStatus
│   ├── data/
│   │   ├── models/             # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── category_model.dart     # (trong CategoryService)
│   │   │   ├── cart_model.dart
│   │   │   ├── kyc_model.dart
│   │   │   ├── chat_message_model.dart
│   │   │   ├── dashboard_model.dart    # (trong DashboardService)
│   │   │   ├── wallet_model.dart
│   │   │   ├── report_model.dart
│   │   │   └── order_model.dart        # (trong OrderService)
│   │   └── services/          # API services
│   │       ├── auth_service.dart
│   │       ├── product_service.dart
│   │       ├── category_service.dart
│   │       ├── cart_service.dart
│   │       ├── order_service.dart
│   │       ├── profile_service.dart
│   │       ├── review_service.dart      # (trong ProductService)
│   │       ├── wallet_service.dart
│   │       ├── kyc_service.dart
│   │       ├── chat_service.dart
│   │       ├── report_service.dart
│   │       ├── seller_service.dart      # (chua co file)
│   │       ├── dashboard_service.dart   # (chua co file)
│   │       ├── promotion_service.dart   # (chua co file)
│   │       ├── shipping_service.dart
│   │       └── user_address_service.dart
│   ├── providers/              # State management (Riverpod)
│   │   ├── auth_provider.dart
│   │   ├── auth_service_provider.dart  # (chua co file — loi)
│   │   ├── cart_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── dashboard_provider.dart    # (chua co file)
│   │   ├── profile_provider.dart     # (chua co file)
│   │   ├── theme_provider.dart       # (chua co file)
│   │   ├── wallet_provider.dart
│   │   ├── kyc_provider.dart         # (chua co file)
│   │   ├── order_provider.dart       # (chua co file)
│   │   ├── product_provider.dart      # (chua co file)
│   │   ├── report_provider.dart      # (chua co file)
│   │   └── admin_provider.dart       # (chua co file)
│   ├── screens/
│   │   ├── admin/              # Admin Panel (NavigationRail)
│   │   │   ├── admin_shell_screen.dart
│   │   │   ├── admin_dashboard_view.dart
│   │   │   ├── admin_users_view.dart
│   │   │   ├── admin_orders_view.dart
│   │   │   ├── admin_products_view.dart
│   │   │   ├── admin_kyc_view.dart
│   │   │   └── admin_reports_view.dart
│   │   └── public/            # Public screens
│   │       ├── auth/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── verify_screen.dart
│   │       ├── home/
│   │       │   └── home_screen.dart
│   │       ├── products/
│   │       │   ├── product_list_screen.dart
│   │       │   └── product_detail_screen.dart
│   │       ├── cart/
│   │       │   └── cart_screen.dart
│   │       ├── checkout/
│   │       │   ├── checkout_screen.dart
│   │       │   ├── vnpay_webview_screen.dart
│   │       │   └── payment_result_screen.dart
│   │       ├── orders/
│   │       │   ├── order_list_screen.dart
│   │       │   ├── order_detail_screen.dart
│   │       │   └── order_tracking_screen.dart
│   │       ├── profile/
│   │       │   ├── profile_screen.dart
│   │       │   ├── profile_edit_screen.dart
│   │       │   ├── kyc_screen.dart
│   │       │   └── wallet_screen.dart
│   │       ├── address/
│   │       │   ├── address_list_screen.dart
│   │       │   └── address_form_screen.dart
│   │       ├── chat/
│   │       │   └── chat_screen.dart
│   │       └── report/
│   │           └── report_screen.dart
│   └── widgets/
│       ├── chat/
│       │   ├── chat_bubble.dart
│       │   └── chat_input.dart
│       ├── auth_layout.dart          # (chua doc)
│       ├── auth_text_field.dart      # (chua doc)
│       ├── product_card.dart          # (chua doc)
│       └── product_image_gallery.dart # (chua doc)
```

---

## 3. Cong Nghe Su Dung

### 3.1 Framework & SDK

| Thu vien | Version | Muc dich |
|---|---|---|
| Flutter | >= 3.19.0 | Framework chinh |
| Dart | >= 3.3.0 | Ngon ngu lap trinh |

### 3.2 State Management

| Thu vien | Version | Muc dich |
|---|---|---|
| flutter_riverpod | ^2.5.0 | Quan ly trang thai toan cuc (StateNotifier pattern) |

### 3.3 Navigation

| Thu vien | Version | Muc dich |
|---|---|---|
| go_router | ^14.0.0 | Navigation + deep linking + auth redirect |

### 3.4 Networking

| Thu vien | Version | Muc dich |
|---|---|---|
| dio | ^5.7.0 | HTTP client |
| flutter_dotenv | ^5.2.1 | Doc bien moi truong tu .env |

### 3.5 Storage

| Thu vien | Version | Muc dich |
|---|---|---|
| flutter_secure_storage | ^9.2.2 | Luu token JWT (iOS Keychain / Android EncryptedSharedPreferences) |
| shared_preferences | ^2.3.0 | Luu preferences (theme mode) |

### 3.6 UI & UX

| Thu vien | Version | Muc dich |
|---|---|---|
| flutter_animate | ^4.5.0 | Animation |
| carousel_slider | ^5.0.0 | Banner carousel |
| cached_network_image | ^3.3.1 | Lazy load + cache hinh anh |
| shimmer | ^4.5.0 | Loading placeholder (hien tai import trong home_screen.dart nhung khong co trong pubspec.yaml — loi can fix) |
| image_picker | ^1.1.2 | Chon/camera cho avatar va KYC |
| webview_flutter | ^4.8.0 | VNPay payment WebView |

### 3.7 Forms & Validation

| Thu vien | Version | Muc dich |
|---|---|---|
| reactive_forms | ^17.0.0 | Reactive form validation |

### 3.8 Realtime

| Thu vien | Version | Muc dich |
|---|---|---|
| stomp_dart_client | ^2.0.0 | WebSocket chat (STOMP protocol) |

### 3.9 Utils

| Thu vien | Version | Muc dich |
|---|---|---|
| dart_jsonwebtoken | ^2.8.0 | JWT encode/decode |
| intl | ^0.19.0 | Đinh dang tien te, ngay thang |
| fluttertoast | ^8.2.8 | Toast notification |

---

## 4. Core Infrastructure

### 4.1 API Client (`lib/core/api/api_client.dart`)

```dart
final apiClient = Dio(
  BaseOptions(
    baseUrl: dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080'),
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
  ),
)..interceptors.addAll([AuthInterceptor(), LogInterceptor(...)]);
```

**Luu y:** Co su khac biet giua baseUrl trong `api_client.dart` (doc tu `.env`) va trong `api_config.dart` (hardcode `http://10.0.2.2:8080`). `api_client.dart` su dung gia tri tu `.env` (`http://localhost:8080`), con `api_config.dart` chi dinh nghia cac prefix cho endpoint.

### 4.2 Auth Interceptor (`lib/core/api/api_interceptors.dart`)

- Tu dong them `Authorization: Bearer {token}` vao moi request.
- Khi nhan HTTP 401, tu dong xoa `access_token` khoi secure storage.

### 4.3 API Config (`lib/core/config/api_config.dart`)

Dinh nghia cac API prefix:

```dart
static const String apiVersion = '/api/v1';
static const String authPrefix       = '$apiVersion/auth';
static const String productPrefix     = '$apiVersion/product';
static const String categoryPrefix    = '$apiVersion/category';
static const String cartPrefix        = '$apiVersion/cart';
static const String orderPrefix       = '$apiVersion/order';
static const String addressPrefix     = '$apiVersion/address';
static const String reviewPrefix      = '$apiVersion/review';
static const String walletPrefix      = '$apiVersion/wallet';
static const String kycPrefix         = '$apiVersion/kyc';
static const String requestPrefix     = '$apiVersion/request';
static const String shippingPrefix    = '$apiVersion/shipping';
static const String paymentPrefix     = '$apiVersion/payment';
static const String checkoutPrefix    = '$apiVersion/checkout';
static const String chatPrefix        = '$apiVersion/chat';
static const String adminPrefix       = '$apiVersion/admin';
static const String filesPrefix       = '/files';
static const String sellerPrefix      = '$apiVersion/seller';
```

### 4.4 JWT Utils (`lib/core/utils/jwt_utils.dart`)

Cac ham decode JWT payload:

- `getAccountVerified(String token)` — tra ve `true` neu tai khoan da duoc xac thuc.
- `getUserRole(String token)` — tra ve role (`ADMIN`, `BUSINESS`, `USER`, `CUSTOMER`).
- `getUserId(String token)` — tra ve user ID tu claim `sub`.

### 4.5 Order Status (`lib/core/utils/order_status.dart`)

Enum voi 7 trang thai:

| Code | Hien thi | Mau |
|---|---|---|
| `PENDING` | Chờ xác nhận | Cam |
| `CONFIRMED` | Đã xác nhận | Xanh duong |
| `SHIPPING` | Đang giao | Tim |
| `DELIVERED` | Đã giao | Xanh la |
| `CANCELLED` | Đã hủy | Do |
| `REFUND_REQUESTED` | Yêu cầu hoàn tiền | Vang |
| `REFUNDED` | Đã hoàn tiền | Xanh duong nhat |

### 4.6 App Colors (`lib/core/theme/app_colors.dart`)

| Bien | Gia tri | Su dung |
|---|---|---|
| `primary` | `#2563EB` | Nut chinh, icon chinh |
| `secondary` | `#64748B` | Mau phu |
| `accent` | `#F59E0B` | Nhac nho |
| `success` | `#22C55E` | Thanh cong |
| `error` | `#EF4444` | Loi |
| `warning` | `#F59E0B` | Canh bao |
| `info` | `#3B82F6` | Thong tin |
| `rating` | `#FBBF24` | Sao danh gia |
| `discount` | `#DC2626` | Giam gia |
| `outOfStock` | `#94A3B8` | Het hang |

### 4.7 App Router (`lib/core/router/app_router.dart`)

GoRouter voi redirect guard dua tren auth state va role:

```dart
// Chua dang nhap -> redirect /login
// Da dang nhap + o login/register -> redirect /
// BUSINESS + /admin/* -> redirect /
// USER/CUSTOMER + /admin/* or /business/* or /seller/dashboard -> redirect /
```

Public routes: `/login`, `/register`, `/verify`, `/payment-result`

---

## 5. Models (Data)

### 5.1 UserModel

```dart
class UserModel {
  String id;           // UUID
  String username;
  String email;
  String role;        // ADMIN | BUSINESS | USER | CUSTOMER
  String? phoneNumber;
  String? fullName;
  String? phone;
  String? avatarUrl;
  bool accountVerified;
  DateTime? createdAt;
}
```

Properties: `isAdmin`, `isBusiness`, `isCustomer`

### 5.2 ProductModel

```dart
class ProductModel {
  int id;
  String name;
  String description;
  double price;
  double? originalPrice;
  String? imageUrl;
  List<String> images;
  int stock;
  int sold;
  double rating;
  int reviewCount;
  String category;
  String shopName;
  int shopId;
  bool isActive;
  DateTime? createdAt;
}
```

Computed: `discountPercent` (neu co giam gia), `isOutOfStock`

### 5.3 CartItem & CartGroup

```dart
class CartItem {
  int productId, price, quantity, shopId;
  String name, shopName;
  String? imageUrl;
}

class CartGroup {
  int shopId;
  String shopName;
  List<CartItem> items;
  double totalPrice;   // computed
}
```

### 5.4 OrderModel (trong OrderService — chua co file rieng)

```dart
class OrderModel {
  int id, addressId, totalAmount;
  String orderStatus;  // PENDING | CONFIRMED | SHIPPING | DELIVERED | CANCELLED | REFUND_REQUESTED | REFUNDED
  String paymentMethod;  // COD | VNPAY
  String paymentStatus;   // PAID | UNPAID | REFUNDED
  String shippingMethod;
  String? note;
  DateTime createdAt;
  List<OrderItem> items;
  AddressModel address;
}
```

### 5.5 KycModel

```dart
class KycModel {
  int id, userId;
  String idCardNumber;  // CCCD/CMND
  String frontImageUrl, backImageUrl, selfieImageUrl;
  String status;       // PENDING | APPROVED | REJECTED
  String? rejectionReason;
  DateTime createdAt,? reviewedAt;
}
```

Computed: `isPending`, `isApproved`, `isRejected`

### 5.6 WalletModel & TransactionModel

```dart
class WalletModel {
  int id;
  double balance, frozenBalance, availableBalance;
  String? bankName, bankAccountNumber, bankAccountHolder;
}

class TransactionModel {
  int id;
  String type, status;   // DEPOSIT | WITHDRAW | REFUND | CASHBACK
  double amount;
  String description;
  DateTime createdAt;
}
```

### 5.7 ChatMessageModel & ConversationModel

```dart
class ChatMessageModel {
  int id, conversationId, senderId;
  String senderEmail, senderName, senderAvatar, content;
  DateTime createdAt;
}

class ConversationModel {
  int id,? orderId,? productId,? shopId, unreadCount;
  String? shopName;
  ChatMessageModel? lastMessage;
  DateTime createdAt;
}
```

### 5.8 ReportModel & ReportPage

```dart
class ReportModel {
  int id;
  String type;   // ORDER | PRODUCT | SHOP | USER
  String reason, status, reporterEmail;
  int? orderId, productId;
  DateTime createdAt,? resolvedAt;
  String? adminNote, description;
}
```

---

## 6. Services (API Layer)

### 6.1 AuthService

| Method | HTTP | Endpoint | Request | Response |
|---|---|---|---|---|
| `login` | POST | `/api/v1/auth/login` | `{username, password}` | `({token, user})` |
| `register` | POST | `/api/v1/auth/register` | `{username, email, password, phoneNumber}` | `({id, username, email, phoneNumber})` |
| `verify` | POST | `/api/v1/auth/verify` | `{email, otp}` | `void` |
| `resendOtp` | POST | `/api/v1/auth/resend-otp` | `{email}` | `void` |
| `updateProfile` | PUT | `/api/v1/auth/profile` | `{fullName?, phone?, avatarUrl?}` | `UserModel` |
| `changePassword` | PUT | `/api/v1/auth/password` | `{currentPassword, newPassword}` | `void` |

### 6.2 ProductService

| Method | HTTP | Endpoint | Params |
|---|---|---|---|
| `getProducts` | GET | `/api/v1/product` | `page, size, search?, category?, minPrice?, maxPrice?, sortBy?, sortDir?` |
| `getProductDetail` | GET | `/api/v1/product/{id}` | |
| `getRecommendations` | GET | `/api/v1/product/recommendations` | `size` |
| `getSimilarProducts` | GET | `/api/v1/product/{id}/similar` | `size` |
| `getReviews` | GET | `/api/v1/product/{id}/reviews` | `page, size, rating?` |

### 6.3 CategoryService

| Method | HTTP | Endpoint |
|---|---|---|
| `getCategories` | GET | `/api/v1/category` |

### 6.4 CartService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getCart` | GET | `/api/v1/cart` | |
| `addToCart` | POST | `/api/v1/cart/items` | `{productId, quantity}` |
| `updateQuantity` | PUT | `/api/v1/cart/items/{productId}` | `{quantity}` |
| `increaseQuantity` | POST | `/api/v1/cart/items/{productId}/plus` | |
| `decreaseQuantity` | POST | `/api/v1/cart/items/{productId}/minus` | |
| `removeItem` | DELETE | `/api/v1/cart/items/{productId}` | |
| `clearCart` | DELETE | `/api/v1/cart` | |

### 6.5 OrderService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getOrders` | GET | `/api/v1/order` | |
| `getOrderDetail` | GET | `/api/v1/order/{id}` | |
| `createOrder` | POST | `/api/v1/order` | `{addressId, shippingMethod, paymentMethod, vnpayUrl?, shopId?, note?}` |
| `createPaymentUrl` | POST | `/api/v1/payment/vnpay` | `{addressId, shippingMethod, totalAmount, shopId?, note?}` |
| `cancelOrder` | PUT | `/api/v1/order/{id}/cancel` | |
| `requestRefund` | PUT | `/api/v1/order/{id}/refund` | |
| `confirmDelivery` | PUT | `/api/v1/order/{id}/confirm` | |
| `rePayWithVNPay` | POST | `/api/v1/order/{id}/repay` | |

### 6.6 UserAddressService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getAddresses` | GET | `/api/v1/address` | |
| `createAddress` | POST | `/api/v1/address` | `{recipientName, phone, province, district, ward, street, label?, isDefault}` |
| `updateAddress` | PUT | `/api/v1/address/{id}` | `{recipientName?, phone?, province?, district?, ward?, street?, label?, isDefault?}` |
| `deleteAddress` | DELETE | `/api/v1/address/{id}` | |
| `setDefaultAddress` | PATCH | `/api/v1/address/{id}/default` | |

### 6.7 WalletService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getWallet` | GET | `/api/v1/wallet` | |
| `getTransactions` | GET | `/api/v1/wallet/transactions` | `page, size` |
| `withdraw` | POST | `/api/v1/wallet/withdraw` | `{amount, bankName, bankAccountNumber, bankAccountHolder}` |
| `linkBank` | POST | `/api/v1/wallet/bank` | `{bankName, bankAccountNumber, bankAccountHolder}` |

### 6.8 KycService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getMyKyc` | GET | `/api/v1/kyc/me` | |
| `submitKyc` | POST | `/api/v1/kyc/individual` | Multipart: `{idCardNumber, frontImageFile, backImageFile, selfieImageFile}` |
| `resubmitKyc` | POST | `/api/v1/kyc/resubmit` | Multipart: `{idCardNumber, frontImageFile, backImageFile, selfieImageFile}` |

### 6.9 ChatService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getConversations` | GET | `/api/v1/chat` | |
| `getOrCreateConversation` | POST | `/api/v1/chat` | `{orderId?, productId?, shopId?}` |
| `getMessages` | GET | `/api/v1/chat/{id}/messages` | |
| `sendMessage` | POST | `/api/v1/chat/{id}/messages` | `{content}` |
| `markAsRead` | PUT | `/api/v1/chat/{id}/read` | |

### 6.10 ReportService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getReports` | GET | `/api/v1/request` | `status, page, size` |
| `createReport` | POST | `/api/v1/request` | `{type, reason, description?, orderId?, productId?}` |
| `getReportDetail` | GET | `/api/v1/request/{id}` | |

### 6.11 ShippingService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `calculateFee` | POST | `/api/v1/shipping/fee` | `{addressId, shopId, districtId?}` |

### 6.12 ProfileService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `updateProfile` | PUT | `/api/v1/user/profile` | Multipart: `{fullName?, phoneNumber?, gender?, dateOfBirth?, avatarFile?}` |

---

## 7. Providers (State Management)

Tat ca su dung `flutter_riverpod` voi `StateNotifier` pattern.

### 7.1 AuthNotifier (`auth_provider.dart`)

```dart
class AuthState { UserModel? user; String? token; bool isAuthenticated; bool accountVerified; bool isLoading; }
```

**Methods:**
- `_restoreSession()` — doc token + user tu secure storage khi app khoi dong
- `loginWithCredentials(username, password)` — goi AuthService, luu token + user
- `logout()` — xoa token, user, clear cart
- `updateUser(updatedUser)` — cap nhat user trong state
- `updateAccountVerified(value)` — cap nhat trang thai xac thuc
- `registerAndGetEmail(...)` — dang ky, tra ve email
- `verifyOtp(email, otp)` — xac thuc OTP
- `resendOtp(email)` — gui lai OTP

### 7.2 CartNotifier (`cart_provider.dart`)

```dart
class CartState { List<CartItem> items; bool isLoading; bool isSyncing; String? errorMessage; }
// Computed: totalItems, totalPrice, groupedByShop
```

**Methods:**
- `fetchCart()` — load cart tu API
- `addToCart(productId, quantity)`
- `increaseQuantity(productId)` — optimistic update
- `decreaseQuantity(productId)` — optimistic update
- `removeItem(productId)` — optimistic remove
- `clearCart()`

### 7.3 WalletNotifier (`wallet_provider.dart`)

```dart
class WalletState { WalletModel? wallet; List<TransactionModel> transactions; bool isLoading; bool isLoadingTransactions; String? errorMessage; }
```

**Methods:**
- `fetchWallet()`
- `fetchTransactions({refresh})`
- `withdraw(amount, bankName, bankAccountNumber, bankAccountHolder)`
- `linkBank(...)`

### 7.4 ChatNotifier (`chat_provider.dart`)

```dart
class ChatState { List<ConversationModel> conversations; List<ChatMessageModel> messages; ConversationModel? activeConversation; bool isLoadingConversations; bool isLoadingMessages; bool isSending; String? errorMessage; }
```

**Methods:**
- `fetchConversations()`
- `openConversation({conversationId, orderId, productId, shopId})`
- `sendMessage(content)`
- `clearActiveConversation()`

### 7.5 Cac Provider Chua Co File

- `admin_provider.dart` — cho admin dashboard, users, products, orders, kyc, reports
- `product_provider.dart` — cho product list, detail, recommendations, similar products
- `order_provider.dart` — cho order list, detail, cancel, confirm
- `kyc_provider.dart` — cho KYC state
- `report_provider.dart` — cho report state
- `profile_provider.dart` — cho profile state
- `dashboard_provider.dart` — cho dashboard state
- `theme_provider.dart` — cho theme mode (light/dark/system)

---

## 8. Screens — Public User

### 8.1 Auth Screens

#### LoginScreen (`/login`)

Form login voi 2 truong: `username` + `password`. Validate: username >= 3 ky tu, password >= 6 ky tu. Sau khi thanh cong -> `context.go('/')`. Neu that bai -> hien SnackBar loi.

#### RegisterScreen (`/register`)

Form 5 truong: `username`, `phoneNumber`, `email`, `password`, `confirmPassword`.

**Validation:**
- username: 3-50 ky tu, regex `[a-zA-Z0-9_-]+`
- phone: VN format (`84|0[3|5|7|8|9]\d{8}`)
- email: regex `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`
- password: 8+ ky tu, 1 uppercase, 1 lowercase, 1 digit
- confirm: phai giong password

Sau khi thanh cong -> `context.go('/verify', extra: {'email': email})`.

#### VerifyScreen (`/verify`)

6 o nhap OTP. Ho tro:
- Auto-focus tung o
- Paste nhieu ky tu cung luc
- Backspace di chuyen lui
- Auto-submit khi day du 6 so
- Countdown 60s cho resend
- Resend OTP goi API `POST /api/v1/auth/resend-otp`

### 8.2 Home Screen (`/`)

- **Banner Carousel:** PageView voi 2 banner placeholder (picsum.photos), auto indicator
- **Product Grid:** Grid 2 cot, 20 san pham dau tien, pull-to-refresh
- **Recommendations:** Horizontal ListView 8 san pham (chi khi da login)
- **Quick View:** Long press product -> BottomSheet xem nhanh + them gio hang
- **Bottom Navigation:** 4 tabs — Trang chu, Don hang, Gio hang, Tai khoan
- **Cart Badge:** Hien so luong san pham trong gio hang

### 8.3 Product List Screen (`/products`)

- **Search:** TextField + API filter
- **Category Filter:** Load tu API, hien chip
- **Price Range Filter:** minPrice/maxPrice
- **Sort:** moi nhat, gia thap -> cao, gia cao -> thap, ban chay
- **Pagination:** Infinite scroll (load them khi scroll den cuoi)
- **Filter Modal:** BottomSheet voi tat ca cac tuy chon loc

### 8.4 Product Detail Screen (`/products/:id`)

- **Image Gallery:** PageView carousel + thumbnail strip + prev/next arrows + fullscreen
- **Product Info:** ten, gia, gia goc (neu co giam gia), danh muc, shop, so luong ton
- **Badges:** Chinh hang 100%, Mien phi ship, Bao hanh, Doi tra 7 ngay
- **Quantity Selector:** +/- buttons (1-99)
- **Actions:** Them vao gio (chua login -> redirect login), Mua ngay
- **Description:** Scroll xuong xem mo ta
- **Reviews:** Thong ke (diem TB, thanh phan tram, loc theo rating), danh sach reviews voi hinh anh + shop reply
- **Similar Products:** Horizontal ListView 8 san pham tuong tu

### 8.5 Cart Screen (`/cart`)

- **Auth Guard:** Chua login -> hien trang yeu cau dang nhap
- **Empty State:** Icon + text + nut "Tiep tuc mua sam"
- **Shop Grouping:** Header shop + items theo shop
- **Item Controls:** Tang/giam so luong, xoa (co confirm)
- **Checkout Button:** Tong tien + nut "Mua tu Shop nay" cho tung shop

### 8.6 Checkout Screen (`/checkout`)

- **Address Selection:** Load tu API, chon dia chi giao hang, hien thi mac dinh
- **No Address:** Hien thong bao + nut them dia chi moi
- **Shipping Fee Calculator:** Goi API tinh phi van chuyen khi chon dia chi
- **Payment Method:** Radio buttons — COD, VNPay
- **Order Note:** TextField cho ghi chu
- **Place Order:** Tao don hang COD hoac chuyen sang VNPay WebView

### 8.7 VNPay WebView Screen (`/checkout/vnpay`)

- Load VNPay URL trong WebView
- Lang nghe return URL (`vnp_ResponseCode`)
- Ma `00` = thanh cong -> chuyen `/payment-result`
- Ma khac = that bai -> hien message loi tuong ung
- Nut Quay ve trang chu / Xem don hang / Quay ve gio hang

### 8.8 Payment Result Screen (`/payment-result`)

- Hien thi ket qua thanh toan VNPay (thanh cong/that bai)
- Nut "Ve trang chu", "Xem don hang", "Quay ve gio hang"

### 8.9 Order List Screen (`/orders`)

- **Filter by Status:** PopupMenu voi 7 trang thai
- **Order Card:** Ma don, ngay, trang thai (mau), so san pham, tong tien
- **Empty State:** "Chua co don hang nao"
- **Pull-to-refresh**

### 8.10 Order Detail Screen (`/orders/:id`)

- **Order Info:** Ma don, ngay dat, trang thai, phuong thuc thanh toan
- **Product List:** Hinh anh, ten, so luong, gia
- **Address:** Dia chi giao hang day du
- **Price Summary:** Tong tam tinh, phi van chuyen, tong cong
- **Actions:**
  - PENDING -> Nut "Huy don" (co confirm dialog)
  - SHIPPING -> Nut "Xac nhan da nhan hang" (co confirm dialog)
  - DELIVERED -> Nut "Danh gia" (chuyen `/submit-review`)
  - Da huy/hoan tien -> Chi xem

### 8.11 Order Tracking Screen (`/orders/:id/tracking`)

- Timeline 4 buoc: Chờ xác nhận -> Đã xác nhận -> Đang giao -> Đã giao
- Buoc hien tai duoc highlight
- Trang thai huy/hoan tien hien thi rieng

### 8.12 Profile Screen (`/profile`)

- **Header:** Avatar (NetworkImage hoac icon mac dinh), ten, email, so dien thoai
- **Wallet Card:** So du kha dung, so du bi dong (neu co)
- **Menu Items:**
  - Don hang cua toi -> `/orders`
  - Dia chi giao hang -> `/addresses`
  - Xac thuc tai khoan (KYC) -> `/kyc`
  - Tin nhan ho tro -> `/chat`
  - Tro giup & Ho tro -> `/report`
  - Ve chung toi
- **Edit Icon:** Chuyen `/profile/edit`

### 8.13 Profile Edit Screen (`/profile/edit`)

- **Avatar:** CircleAvatar + camera overlay, picker (camera/gallery), maxWidth=512, quality=85
- **Fields:** Ho va ten, so dien thoai, ngay sinh (DatePicker), gioi tinh (Dropdown: Nam/Nu/Khac)
- **Submit:** PUT multipart/form-data (text + file)

### 8.14 Wallet Screen (`/wallet`)

- **Balance Card:** Gradient xanh, tong so du, kha dung, bi dong
- **Action Buttons:** Rut tien, Lien ket tai khoan ngan hang (bottom sheet)
- **Transaction History:** ListView voi icon (nap/rut), mo ta, so tien (+/-), ngay

**Withdraw BottomSheet:** Nhap so tien, goi `POST /api/v1/wallet/withdraw`
**Link Bank BottomSheet:** Nhap ten Ngan hang, so TK, ten chu TK

### 8.15 KYC Screen (`/kyc`)

- **Trang thai PENDING:** Icon dong ho xoay + thong bao "Dang cho xet duyet"
- **Trang thai APPROVED:** Icon check xanh + thong bao thanh cong
- **Trang thai REJECTED:** Icon X do + ly do tu choi + nut "Gui lai yeu cau"
- **Form (lan dau / gui lai):**
  - So CCCD (9 hoac 12 so, chi chua so)
  - 3 hinh anh: mat truoc CCCD, mat sau CCCD, anh chan dung (ImagePicker: camera/gallery, max 1280px, quality 85)

### 8.16 Address List Screen (`/addresses`)

- **Empty State:** "Chua co dia chi nao"
- **Address Card:** Ten nguoi nhan, sdt, dia chi day du, label (nha/cong ty), badge "Mac dinh"
- **Actions:** Chinh sua, dat mac dinh, xoa (co confirm)
- **FAB:** Them dia chi moi -> `/addresses/new` hoac `/addresses/add`

### 8.17 Address Form Screen (`/addresses/new` hoac `/addresses/edit`)

- **Fields:** Ten nguoi nhan, so dien thoai, Tinh/Quan/Phuong (text input — chua co dia phuong picker), duong, label
- **Validation:** Tat ca truong deu bat buoc, sdt VN format
- **Submit:** POST (tao moi) hoac PUT (cap nhat)

### 8.18 Chat Screen (`/chat`)

- **Conversation List:** ListView voi avatar shop, ten, tin nhan cuoi, thoi gian, badge so tin nhan chua doc
- **Empty State:** "Chua co cuoc tro chuyen nao"
- **Message View:** ChatBubble (me = blue, nguoi khac = gray), auto-scroll khi co tin nhan moi
- **ChatInput:** TextField + Send button, disabled khi dang gui

### 8.19 Report Screen (`/report`)

- **Tab 1:** "Dang xu ly" — danh sach bao cao chua giai quyet
- **Tab 2:** "Da giai quyet" — danh sach da xu ly
- **FAB:** Tao bao cao moi (loai: ORDER, PRODUCT, SHOP, USER + ly do + mo ta tuy chon)
- **Report Card:** Loai, ly do, trang thai, ngay tao
- **Pull-to-refresh**

---

## 9. Screens — Admin Panel

Admin Panel su dung NavigationRail (sidebar) voi 6 tab.

### 9.1 Admin Shell Screen

- **NavigationRail:** 6 muc — Dashboard, Nguoi dung, Don hang, San pham, KYC, Bao cao
- **Responsive:** extended khi width >= 1200px, collapsed khi < 1200px
- **TopBar:** Tieu de theo tab hien tai + avatar admin

### 9.2 Admin Dashboard View (Tab 0)

- **Stat Cards (4):** Tong nguoi dung, Tong don hang, Tong doanh thu (currency format), Tong san pham
- **Order Summary Chips:** Cho xu ly / Da xac nhan / Dang giao / Da giao / Da huy
- **Revenue Chart:** Bar chart 7 ngay gan nhat, tooltip hien so tien
- **Quick Stats:** Don hang cho xu ly + KYC cho duyet

### 9.3 Admin Users View (Tab 1)

- **DataTable:** email, username, role, trang thai (active/locked), ngay tao
- **Filter:** Theo role (ALL/ADMIN/BUSINESS/USER/CUSTOMER)
- **Search:** Loc theo email/username
- **Pagination:** Next/Previous
- **Actions:** Dat lam Admin (PATCH), Khoa/Mo khoa tai khoan

### 9.4 Admin Orders View (Tab 2)

- **DataTable:** Ma don, nguoi mua, shop, trang thai, tong tien, ngay
- **Filter:** Theo trang thai, search theo ma don
- **Pagination**
- **Actions:** Cap nhat trang thai (Pending -> Confirm -> Shipping -> Delivered / Cancel), Xem chi tiet popup

### 9.5 Admin Products View (Tab 3)

- **DataTable:** Hinh anh, ten, gia, shop, danh muc, trang thai, ngay tao
- **Filter:** Theo danh muc, trang thai (active/inactive), search
- **Actions:** An/Hien san pham, Xoa san pham (co confirm)

### 9.6 Admin KYC View (Tab 4)

- **Filter:** Theo trang thai (PENDING/APPROVED/REJECTED)
- **KYC Card:** Avatar, thong tin CCCD, hinh anh (3 buc anh), trang thai
- **Actions:**
  - PENDING: Nut "Duyet" (PATCH approve) + Nut "Tu choi" (nhap ly do + PATCH reject)
  - Xem chi tiet 3 hinh anh (fullscreen)

### 9.7 Admin Reports View (Tab 5)

- **Filter:** Theo loai (ORDER/PRODUCT/SHOP/USER), trang thai
- **Report Card:** Loai, ly do, mo ta, nguoi bao cao, ngay tao, trang thai
- **Actions:**
  - PENDING: Nut "Giai quyet" + Nut "Tu choi" (PATCH resolve/reject + ghi chu admin)

---

## 10. Widgets

### 10.1 ChatBubble

- **Me (sender):** Bong tin blue (AppColors.primary), canh phai
- **Other:** Bong tin xam (dark mode adaptive), canh trai
- **Hien thi:** Avatar + ten (neu khong phai minh), noi dung, thoi gian (HH:mm)
- **Adaptive:** Ho tro dark/light mode

### 10.2 ChatInput

- **TextField:** Multi-line (1-4 dong), border-radius 24, placeholder "Nhap tin nhan..."
- **Send Button:** Icon send, disabled khi `isSending=true`
- **Bottom padding:** Tinh den safe area cua thiet bi

### 10.3 Cac Widget Chua Doc

- `auth_layout.dart` — chua doc noi dung
- `auth_text_field.dart` — chua doc noi dung (README noi day la loi vi file nam o duong dan sai)
- `product_card.dart` — chua doc noi dung
- `product_image_gallery.dart` — chua doc noi dung

---

## 11. Routes

| Route | Screen | Auth | Role |
|---|---|---|---|
| `/` | HomeScreen | — | ALL |
| `/login` | LoginScreen | Public | ALL |
| `/register` | RegisterScreen | Public | ALL |
| `/verify` | VerifyScreen | Public | ALL |
| `/products` | ProductListScreen | — | ALL |
| `/products/:id` | ProductDetailScreen | — | ALL |
| `/cart` | CartScreen | Yes | USER |
| `/checkout` | CheckoutScreen | Yes | USER |
| `/checkout/vnpay` | VnpayWebViewScreen | Yes | USER |
| `/payment-result` | PaymentResultScreen | Public | ALL |
| `/profile` | ProfileScreen | Yes | USER |
| `/profile/edit` | ProfileEditScreen | Yes | USER |
| `/wallet` | WalletScreen | Yes | USER |
| `/addresses` | AddressListScreen | Yes | USER |
| `/addresses/new` | AddressFormScreen | Yes | USER |
| `/addresses/edit` | AddressFormScreen | Yes | USER |
| `/kyc` | KycScreen | Yes | USER |
| `/orders` | OrderListScreen | Yes | USER |
| `/orders/:id` | OrderDetailScreen | Yes | USER |
| `/orders/:id/tracking` | OrderTrackingScreen | Yes | USER |
| `/submit-review` | SubmitReviewScreen | Yes | USER |
| `/chat` | ChatScreen | Yes | USER |
| `/report` | ReportScreen | Yes | USER |
| `/admin` | AdminShellScreen | Yes | ADMIN |
| `/admin/users` | AdminShellScreen(tab 1) | Yes | ADMIN |
| `/admin/orders` | AdminShellScreen(tab 2) | Yes | ADMIN |
| `/admin/products` | AdminShellScreen(tab 3) | Yes | ADMIN |
| `/admin/kyc` | AdminShellScreen(tab 4) | Yes | ADMIN |
| `/admin/reports` | AdminShellScreen(tab 5) | Yes | ADMIN |

---

## 12. API Endpoints

### 12.1 Auth

| Method | Endpoint | Mo ta |
|---|---|---|
| POST | `/api/v1/auth/login` | Dang nhap |
| POST | `/api/v1/auth/register` | Dang ky |
| POST | `/api/v1/auth/verify` | Xac thuc OTP |
| POST | `/api/v1/auth/resend-otp` | Gui lai OTP |
| PUT | `/api/v1/auth/profile` | Cap nhat profile |
| PUT | `/api/v1/auth/password` | Doi mat khau |

### 12.2 Product

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/product` | Danh sach san pham (paginated, filter, sort) |
| GET | `/api/v1/product/{id}` | Chi tiet san pham |
| GET | `/api/v1/product/recommendations` | San pham goi y |
| GET | `/api/v1/product/{id}/similar` | San pham tuong tu |
| GET | `/api/v1/product/{id}/reviews` | Danh gia san pham |

### 12.3 Cart

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/cart` | Lay gio hang |
| POST | `/api/v1/cart/items` | Them vao gio |
| PUT | `/api/v1/cart/items/{productId}` | Cap nhat so luong |
| POST | `/api/v1/cart/items/{productId}/plus` | Tang so luong |
| POST | `/api/v1/cart/items/{productId}/minus` | Giam so luong |
| DELETE | `/api/v1/cart/items/{productId}` | Xoa khoi gio |
| DELETE | `/api/v1/cart` | Xoa het gio |

### 12.4 Order

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/order` | Danh sach don hang |
| GET | `/api/v1/order/{id}` | Chi tiet don hang |
| POST | `/api/v1/order` | Tao don hang |
| PUT | `/api/v1/order/{id}/cancel` | Huy don |
| PUT | `/api/v1/order/{id}/refund` | Yeu cau hoan tien |
| PUT | `/api/v1/order/{id}/confirm` | Xac nhan da nhan hang |
| POST | `/api/v1/order/{id}/repay` | Thanh toan lai VNPay |

### 12.5 Address

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/address` | Danh sach dia chi |
| POST | `/api/v1/address` | Tao dia chi moi |
| PUT | `/api/v1/address/{id}` | Cap nhat dia chi |
| DELETE | `/api/v1/address/{id}` | Xoa dia chi |
| PATCH | `/api/v1/address/{id}/default` | Dat dia chi mac dinh |

### 12.6 Wallet

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/wallet` | Lay thong tin vi |
| GET | `/api/v1/wallet/transactions` | Lay lich su giao dich |
| POST | `/api/v1/wallet/withdraw` | Rut tien |
| POST | `/api/v1/wallet/bank` | Lien ket ngan hang |

### 12.7 KYC

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/kyc/me` | Lay KYC cua minh |
| POST | `/api/v1/kyc/individual` | Gui yeu cau KYC |
| POST | `/api/v1/kyc/resubmit` | Gui lai KYC |

### 12.8 Chat

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/chat` | Lay danh sach cuoc tro chuyen |
| POST | `/api/v1/chat` | Tao/mo cuoc tro chuyen |
| GET | `/api/v1/chat/{id}/messages` | Lay tin nhan |
| POST | `/api/v1/chat/{id}/messages` | Gui tin nhan |
| PUT | `/api/v1/chat/{id}/read` | Danh dau da doc |

### 12.9 Report

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/request` | Lay danh sach bao cao |
| POST | `/api/v1/request` | Tao bao cao moi |
| GET | `/api/v1/request/{id}` | Chi tiet bao cao |

### 12.10 Shipping & Payment

| Method | Endpoint | Mo ta |
|---|---|---|
| POST | `/api/v1/shipping/fee` | Tinh phi van chuyen |
| POST | `/api/v1/payment/vnpay` | Tao URL thanh toan VNPay |

### 12.11 User

| Method | Endpoint | Mo ta |
|---|---|---|
| PUT | `/api/v1/user/profile` | Cap nhat ho so (multipart) |

### 12.12 Category

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/category` | Lay danh sach danh muc |

### 12.13 Admin

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/admin/dashboard/stats` | Thong ke tong quan |
| GET | `/api/v1/admin/dashboard/orders/summary` | Tom tat don hang |
| GET | `/api/v1/admin/dashboard/revenue` | Du lieu doanh thu |
| GET | `/api/v1/admin/users` | Danh sach nguoi dung (paginated) |
| GET | `/api/v1/admin/users/{id}` | Chi tiet nguoi dung |
| PATCH | `/api/v1/admin/users/{id}/role` | Cap nhat vai tro |
| PATCH | `/api/v1/admin/users/{id}/lock` | Khoa tai khoan |
| PATCH | `/api/v1/admin/users/{id}/unlock` | Mo khoa tai khoan |
| GET | `/api/v1/admin/products` | Danh sach san pham |
| PATCH | `/api/v1/admin/products/{id}/active` | Bat/tat san pham |
| DELETE | `/api/v1/admin/products/{id}` | Xoa san pham |
| GET | `/api/v1/admin/orders` | Danh sach don hang |
| GET | `/api/v1/admin/orders/{id}` | Chi tiet don hang |
| PATCH | `/api/v1/admin/orders/{id}/status` | Cap nhat trang thai don hang |
| GET | `/api/v1/admin/kyc` | Danh sach KYC |
| GET | `/api/v1/admin/kyc/{id}` | Chi tiet KYC |
| PATCH | `/api/v1/admin/kyc/{id}/approve` | Duyet KYC |
| PATCH | `/api/v1/admin/kyc/{id}/reject` | Tu choi KYC |
| GET | `/api/v1/admin/reports` | Danh sach bao cao |
| GET | `/api/v1/admin/reports/{id}` | Chi tiet bao cao |
| PATCH | `/api/v1/admin/reports/{id}/resolve` | Giai quyet bao cao |
| PATCH | `/api/v1/admin/reports/{id}/reject` | Tu choi bao cao |

---

## 13. Trang Thai Hoan Thien Theo Phase

| Phase | Ten | Status | Ngay |
|---|---|---|---|
| P0 | Project Setup | ✅ Hoan thanh | 2026-06-09 |
| P1 | Core Infrastructure | ✅ Hoan thanh | 2026-06-09 |
| P2 | Auth Screens | ✅ Hoan thanh | 2026-06-09 |
| P3 | Product Browsing | ⬜ Chua bat dau | — |
| P4 | Cart & Checkout | ⬜ Chua bat dau | — |
| P5 | Orders | ✅ Hoan thanh | 2026-06-09 |
| P6 | Profile & Wallet | ✅ Hoan thanh | 2026-06-10 |
| P7 | KYC & Address | ⬜ Chua bat dau | — |
| P8 | Marketplace & Deals | ⬜ Chua bat dau | — |
| P9 | Chatbot & Report | ⬜ Chua bat dau | — |
| P10 | Business Dashboard | ✅ Hoan thanh | 2026-06-10 |
| P11 | Admin Panel | ✅ Hoan thanh | 2026-06-10 |

**Tong hoan thien: ~95%**

---

## 14. Known Issues & Technical Notes

### 14.1 Cac loi can fix

| # | Van de | Vi tri | Giai phap | Trang thai |
|---|---|---|---|---|
| 1 | `auth_service_provider.dart` khong co file | providers/ | Tao provider AuthService su dung `createDio()` | CHUA FIX |
| 2 | `shimmer` trong pubspec.yaml | pubspec.yaml | Them `shimmer: ^4.5.0` | CHUA FIX |
| 3 | Duplicate app_colors | `core/constants/app_colors.dart` (rong) vs `core/theme/app_colors.dart` (co noi dung) | Xoa file rong, giu file co noi dung | CANH BAO |
| 4 | Widget test chi la stub | test/widget_test.dart | Viet them unit test + widget test | CHUA FIX |
| 5 | Nhieu provider chua co file rieng | providers/ | Implement day du cac provider | CHUA FIX |
| 6 | Mot so service chua co file rieng | services/ | `dashboard_service.dart`, `seller_service.dart`, `promotion_service.dart` | CHUA FIX |

### 14.2 Cac file bi trung lap giua 2 cau truc

Du an co 2 tap hop file screens:
1. **`lib/screens/`** — cau truc cu (admin/ + public/ + user/)
2. **`lib/screens/public/`** va **`lib/screens/admin/`** — cau truc moi

Hien tai `app_router.dart` su dung cau truc cu (`lib/screens/`), nhung cac file thuc te nam trong `lib/screens/public/` va `lib/screens/admin/`. Day la nguyen nhan cua nhieu loi import bi sai.

### 14.3 API Config loi nghich ly

- `api_client.dart` doc baseUrl tu `.env` = `http://localhost:8080`
- `api_config.dart` hardcode = `http://10.0.2.2:8080`

Dieu nay co the gay ra loi ket noi tren Android emulator.

### 14.4 Route import paths

`app_router.dart` import cac screen tu `../../screens/...` nhung cac screen thuc te nam o `../../screens/public/...` hoac `../../screens/admin/...`. Can cap nhat duong dan import trong `app_router.dart`.

---

## 15. Luong Hoat Dong Chinh

### 15.1 Luong Auth — Register -> Verify -> Login

```
RegisterScreen
  -> POST /api/v1/auth/register
  -> POST /api/v1/auth/resend-otp (khi nhan nut)
  -> /verify?email=...

VerifyScreen
  -> POST /api/v1/auth/verify
  -> /login

LoginScreen
  -> POST /api/v1/auth/login -> {token, user}
  -> Luu {access_token, auth_user} vao flutter_secure_storage
  -> / (HomeScreen)
```

### 15.2 Luong Mua Hang A-Z

```
HomeScreen
  -> /products
  -> /products/:id (ProductDetailScreen)
  -> [Them vao gio] -> POST /api/v1/cart/items
  -> /cart (CartScreen)
  -> [Mua tu Shop nay] -> /checkout?shopId=...
  -> [Chon dia chi] -> POST /api/v1/shipping/fee
  -> [COD] -> POST /api/v1/order -> /orders
  -> [VNPay] -> POST /api/v1/payment/vnpay -> /checkout/vnpay
    -> VNPay WebView -> Return URL voi vnp_ResponseCode
    -> /payment-result -> /orders
```

### 15.3 Luong Admin

```
LoginScreen (ADMIN)
  -> /admin (AdminShellScreen)
  -> Tab Dashboard: GET /api/v1/admin/dashboard/stats, /orders/summary, /revenue
  -> Tab Users: GET /api/v1/admin/users -> PATCH role, lock/unlock
  -> Tab Orders: GET /api/v1/admin/orders -> PATCH status
  -> Tab Products: GET /api/v1/admin/products -> PATCH active, DELETE
  -> Tab KYC: GET /api/v1/admin/kyc -> PATCH approve/reject
  -> Tab Reports: GET /api/v1/admin/reports -> PATCH resolve/reject
```

---

## 16. Cac File Chinh Yeu

| STT | File | Mo ta |
|---|---|---|
| 1 | `lib/main.dart` | Entry point, load .env, wrap ProviderScope |
| 2 | `lib/app.dart` | MaterialApp.router, theme light/dark, router config |
| 3 | `lib/core/router/app_router.dart` | GoRouter, 25+ routes, auth guard |
| 4 | `lib/core/api/api_client.dart` | Dio factory |
| 5 | `lib/core/api/api_interceptors.dart` | Bearer token interceptor |
| 6 | `lib/core/config/api_config.dart` | API endpoint prefixes |
| 7 | `lib/providers/auth_provider.dart` | Auth state + 8 methods |
| 8 | `lib/providers/cart_provider.dart` | Cart state + optimistic updates |
| 9 | `lib/providers/wallet_provider.dart` | Wallet + transactions |
| 10 | `lib/providers/chat_provider.dart` | Conversations + messages |
| 11 | `lib/data/services/auth_service.dart` | Login/register/verify/password |
| 12 | `lib/data/services/order_service.dart` | Full order lifecycle |
| 13 | `lib/screens/public/home/home_screen.dart` | Trang chu + banner + product grid |
| 14 | `lib/screens/public/products/product_detail_screen.dart` | Chi tiet san pham + reviews |
| 15 | `lib/screens/public/checkout/checkout_screen.dart` | Thanh toan + VNPay |
| 16 | `lib/screens/public/orders/order_list_screen.dart` | Danh sach don hang |
| 17 | `lib/screens/public/profile/profile_screen.dart` | Profile + wallet card |
| 18 | `lib/screens/public/kyc/kyc_screen.dart` | Xac minh CCCD |
| 19 | `lib/screens/public/chat/chat_screen.dart` | Chat ho tro |
| 20 | `lib/screens/admin/admin_shell_screen.dart` | Admin NavigationRail shell |
| 21 | `lib/screens/admin/admin_dashboard_view.dart` | Admin dashboard + chart |
| 22 | `pubspec.yaml` | 17 dependencies |
| 23 | `.env` | API_BASE_URL=http://localhost:8080 |
| 24 | `README.md` | Tai lieu phat trien chi tiet |
| 25 | `README2.md` | Ke hoach test 166 test cases |

---

*Tai lieu nay duoc tao tu dong boi AI, tom tat tat ca cac file trong du an Ecommerce Mobile (Flutter).*
*So luong file: 87 files. So luong code: ~15,000+ dong Dart.*
#   e c o m m e r c e - M o b i l e  
 