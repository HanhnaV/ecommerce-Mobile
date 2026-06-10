# TaiLieuDuAn.md - Tai Lieu Ky Thuat Chi Tiet Ecommerce Mobile (Flutter)

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
8. [Screens](#8-screens)
9. [Widgets](#9-widgets)
10. [Routes](#10-routes)
11. [API Endpoints](#11-api-endpoints)
12. [Trang Thai Hoan Thien Theo Phase](#12-trang-thai-hoan-thien-theo-phase)
13. [Known Issues & Technical Notes](#13-known-issues--technical-notes)
14. [Luong Hoat Dong Chinh](#14-luong-hoat-dong-chinh)
15. [Cac File Chinh Yeu](#15-cac-file-chinh-yeu)

---

## 1. Tong Quan Du An

- **Ten du an:** Ecommerce Mobile (AirPod Store)
- **Mo ta:** Ung dung di dong thuong mai dien tu (e-commerce) su dung Flutter, di chuyen tu frontend React sang Flutter.
- **Nen tang backend:** Spring Boot (Java) REST API
- **Base URL mac dinh:** `http://localhost:8080` (Android emulator: `http://10.0.2.2:8080`)
- **Ngon ngu:** Dart (Flutter)
- **Flutter SDK:** >= 3.19.0
- **Dart SDK:** >= 3.3.0 (neu su dung Flutter 3.19+) hoac `>=3.11.5` (neu su dung Flutter 3.27+)
- **Trang thai hoan thien:** ~95%

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
├── test/
│   └── widget_test.dart         # Smoke test co ban
├── lib/
│   ├── main.dart                # Entry point
│   ├── app.dart                 # MaterialApp root (go_router + theme)
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart         # Dio instance (Singleton apiClient)
│   │   │   └── api_interceptors.dart   # AuthInterceptor (Bearer token)
│   │   ├── constants/
│   │   │   └── app_colors.dart        # Color constants
│   │   ├── router/
│   │   │   └── app_router.dart       # GoRouter voi auth guard (19 routes)
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Material 3 light theme
│   │   └── utils/
│   │       ├── jwt_utils.dart        # Decode JWT payload
│   │       └── order_status.dart     # Enum OrderStatus (7 trang thai)
│   ├── data/
│   │   ├── models/             # Data models (10 files)
│   │   │   ├── user_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── cart_model.dart
│   │   │   ├── kyc_model.dart
│   │   │   ├── wallet_model.dart
│   │   │   ├── chat_message_model.dart
│   │   │   ├── report_model.dart
│   │   │   ├── review_model.dart
│   │   │   └── dashboard_model.dart
│   │   └── services/          # API services (16 files)
│   │       ├── auth_service.dart
│   │       ├── product_service.dart
│   │       ├── category_service.dart
│   │       ├── cart_service.dart
│   │       ├── order_service.dart
│   │       ├── user_address_service.dart
│   │       ├── kyc_service.dart
│   │       ├── chat_service.dart
│   │       ├── report_service.dart
│   │       ├── shipping_service.dart
│   │       ├── wallet_service.dart
│   │       ├── profile_service.dart
│   │       ├── review_service.dart
│   │       ├── seller_service.dart
│   │       ├── dashboard_service.dart
│   │       └── promotion_service.dart
│   ├── providers/              # State management (Riverpod) (8 files)
│   │   ├── auth_provider.dart
│   │   ├── auth_service_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── wallet_provider.dart
│   │   ├── dashboard_provider.dart
│   │   ├── profile_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── verify_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── flash_sale_screen.dart
│   │   ├── products/
│   │   │   ├── product_list_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── product_filter_modal.dart
│   │   │       └── product_quick_view.dart
│   │   ├── user/
│   │   │   ├── cart/
│   │   │   │   └── cart_screen.dart
│   │   │   ├── checkout/
│   │   │   │   ├── checkout_screen.dart
│   │   │   │   ├── vnpay_webview_screen.dart
│   │   │   │   └── payment_result_screen.dart
│   │   │   ├── orders/
│   │   │   │   ├── order_list_screen.dart
│   │   │   │   ├── order_detail_screen.dart
│   │   │   │   └── submit_review_screen.dart
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── wallet_screen.dart
│   │   │   │   └── kyc_screen.dart
│   │   │   ├── address/
│   │   │   │   ├── address_list_screen.dart
│   │   │   │   └── address_form_screen.dart
│   │   │   ├── chat/
│   │   │   │   └── chat_screen.dart
│   │   │   ├── report/
│   │   │   │   └── report_screen.dart
│   │   │   └── seller/
│   │   │       ├── seller_dashboard_screen.dart
│   │   │       └── seller_registration_screen.dart
│   └── widgets/
│       └── chat/
│           ├── chat_bubble.dart
│           └── chat_input.dart
```

**Tong so file:** 87 files, ~15,699 dong Dart.

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
| shimmer | ^3.0.0 | Loading placeholder |
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
| intl | ^0.19.0 | Dinh dang tien te, ngay thang |
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
)..interceptors.addAll([AuthInterceptor(), LogInterceptor(requestBody: true, responseBody: true)]);
```

**Luu y:** `apiClient` la singleton. Su dung truc tiep trong cac service.

### 4.2 Auth Interceptor (`lib/core/api/api_interceptors.dart`)

- Tu dong them `Authorization: Bearer {token}` vao moi request.
- Khi nhan HTTP 401, tu dong xoa `access_token` khoi secure storage.

### 4.3 API Prefix (trong cac service - khong co file api_config.dart)

Cac service dinh nghia endpoint truc tiep voi base URL:

```dart
// AuthService
POST /api/v1/auth/login
POST /api/v1/auth/register
POST /api/v1/auth/verify
POST /api/v1/auth/resend-otp

// ProductService
GET  /api/v1/product
GET  /api/v1/product/{id}
GET  /api/v1/recommendations
GET  /api/v1/product/{id}/similar

// CartService
GET    /api/v1/cart
POST   /api/v1/cart/items
POST   /api/v1/cart/items/{id}/plus
POST   /api/v1/cart/items/{id}/minus
DELETE /api/v1/cart/items/{id}

// OrderService
GET  /api/v1/order/me
GET  /api/v1/order/{id}/me
POST /api/v1/order
PATCH /api/v1/order/{id}/received
PATCH /api/v1/order/{id}/cancel
POST /api/v1/payment/orders/{id}/vnpay
GET  /api/v1/payment/vnpay/return

// ShippingService
GET  /api/v1/shipping/provinces
GET  /api/v1/shipping/districts?provinceId=
GET  /api/v1/shipping/wards?districtId=
POST /api/v1/shipping/fee

// WalletService
GET /api/v1/wallet/me

// KycService
GET  /api/v1/kyc/me
POST /api/v1/kyc/individual

// ChatService
GET    /api/v1/chat/conversation
GET    /api/v1/chat/{id}/messages
POST   /api/v1/chat/{id}/messages
PATCH  /api/v1/chat/{id}/messages/{msgId}/read

// ReportService
GET  /api/v1/report/me
POST /api/v1/report
GET  /api/v1/report/{id}

// ReviewService
GET  /api/v1/review/products/{productId}
GET  /api/v1/review/products/{productId}/reviews/stats
POST /api/v1/review/products/{productId}

// SellerService
POST /api/v1/seller/register
GET  /api/v1/seller/me
PUT  /api/v1/seller/me
GET  /api/v1/seller/{shopId}/products
GET  /api/v1/seller/{shopId}/orders
PATCH /api/v1/seller/orders/{orderId}/status
POST /api/v1/seller/reviews/{reviewId}/reply

// DashboardService
GET /api/v1/statistics/seller
GET /api/v1/order/shops/{shopId}/top-products

// PromotionService
GET /api/v1/promotions/flash-sale
GET /api/v1/promotions/deals
GET /api/v1/promotions/banners
```

### 4.4 JWT Utils (`lib/core/utils/jwt_utils.dart`)

Cac ham decode JWT payload:

- `getAccountVerified(String token)` - tra ve `true` neu tai khoan da duoc xac thuc.
- `getUserRole(String token)` - tra ve role (`ADMIN`, `BUSINESS`, `USER`, `CUSTOMER`).
- `getUserId(String token)` - tra ve user ID tu claim `sub`.

### 4.5 Order Status (`lib/core/utils/order_status.dart`)

Enum voi 7 trang thai:

| Code | Hien thi | Mau |
|---|---|---|
| `PENDING` | Cho xac nhan | Cam |
| `CONFIRMED` | Da xac nhan | Xanh duong |
| `SHIPPING` | Dang giao | Tim |
| `DELIVERED` | Da giao | Xanh la |
| `CANCELLED` | Da huy | Do |
| `REFUND_REQUESTED` | Yeu cau hoan tien | Vang |
| `REFUNDED` | Da hoan tien | Xanh duong nhat |

### 4.6 App Colors (`lib/core/constants/app_colors.dart`)

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
| `pending` | `#F59E0B` | Trang thai cho |
| `confirmed` | `#3B82F6` | Trang thai da xac nhan |
| `shipping` | `#8B5CF6` | Trang thai dang giao |
| `delivered` | `#22C55E` | Trang thai da giao |
| `cancelled` | `#EF4444` | Trang thai da huy |

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
  int id;
  String email;
  String fullName;
  String role;        // ADMIN | BUSINESS | USER | CUSTOMER
  String? phone;
  String? phoneNumber;
  String? avatarUrl;
  bool accountVerified;
  DateTime? createdAt;
  String? gender;
  DateTime? dateOfBirth;
}
```

### 5.2 ProductModel

```dart
class ProductModel {
  int id;
  String name;
  String? description;
  double basePrice;
  String? sku;
  String? categoryId;
  String? categoryName;
  int? shopId;
  String? shopName;
  String status;           // PUBLISHED | ...
  List<ProductImage> images;
  String? thumbnailUrl;
}
```

Computed: `formattedPrice`, `isPublished`

### 5.3 CartItem & CartState

```dart
class CartItem {
  int id, productId, price, quantity, shopId;
  String name, shopName;
  String? imageUrl;
}

class CartState {
  List<CartItem> items;
  int totalItems;
  double totalPrice;
}
```

### 5.4 OrderModel (trong OrderService - co file rieng)

```dart
class OrderDetail {
  int id;
  String orderCode;
  String status;       // PENDING | CONFIRMED | SHIPPING | DELIVERED | CANCELLED | ...
  int shopId;
  String shopName;
  double totalAmount;
  double shippingFee;
  String? notes;
  List<OrderItem> items;
  AddressInfo? address;
  DateTime? createdAt;
}

class OrderItem {
  int productId;
  String productName;
  double unitPrice;
  int quantity;
  double totalPrice;
  String? imageUrl;
}
```

### 5.5 KycModel

```dart
class KycModel {
  int? id;
  String? frontImageUrl, backImageUrl, selfieImageUrl;
  String? idCardNumber;
  String? status;    // PENDING | APPROVED | REJECTED
  DateTime? submittedAt, reviewedAt;
  String? rejectionReason;
}
```

Enum: `KycStatus.notSubmitted`, `.pending`, `.approved`, `.rejected`

### 5.6 WalletModel

```dart
class WalletModel {
  String walletId;
  String userId;
  String currency;         // VND
  double availableBalance;
  double heldBalance;
  double totalBalance;
}
```

### 5.7 ChatMessageModel & Conversation

```dart
class ChatMessage {
  int id, conversationId;
  String content;
  String senderType;     // USER | ADMIN | BOT
  DateTime createdAt;
  bool isRead;
}

class Conversation {
  int id;
  String userId;
  String status;        // OPEN | CLOSED
  String? lastMessage;
  int unreadCount;
  DateTime? lastMessageAt;
}
```

### 5.8 ReportModel

```dart
class Report {
  int id;
  String reportType;    // ORDER | PRODUCT | SELLER | REVIEW | OTHER
  String reason;
  String? description;
  String status;        // PENDING | RESOLVED | REJECTED
  int? targetId;
  String? targetType;
  DateTime createdAt;
  DateTime? resolvedAt;
  String? adminNote;
}
```

### 5.9 ReviewModel

```dart
class ReviewModel {
  int id, userId, rating;
  String? userFullName, userAvatarUrl;
  String? comment;
  List<String> imageUrls;
  SellerReply? sellerReply;
  DateTime? createdAt;
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

### 6.2 ProductService

| Method | HTTP | Endpoint | Params |
|---|---|---|---|
| `getProducts` | GET | `/api/v1/product` | `page, size, sortBy, sortDir, search?, categoryId?, shopId?, minPrice?, maxPrice?` |
| `getProductById` | GET | `/api/v1/product/{id}` | |
| `getRecommendations` | GET | `/api/v1/recommendations` | `limit` |
| `getSimilarProducts` | GET | `/api/v1/product/{id}/similar` | `limit` |

### 6.3 CategoryService

| Method | HTTP | Endpoint |
|---|---|---|
| `getCategories` | GET | `/api/v1/category` |

### 6.4 CartService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getCart` | GET | `/api/v1/cart` | |
| `addToCart` | POST | `/api/v1/cart/items` | `{productId, quantity}` |
| `increaseQuantity` | POST | `/api/v1/cart/items/{id}/plus` | |
| `decreaseQuantity` | POST | `/api/v1/cart/items/{id}/minus` | |
| `removeItem` | DELETE | `/api/v1/cart/items/{id}` | |

**Luu y:** Khong co `clearCart` endpoint. Chi co xoa tung item.

### 6.5 OrderService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getMyOrders` | GET | `/api/v1/order/me` | `status?` |
| `getMyOrderById` | GET | `/api/v1/order/{id}/me` | |
| `createOrder` | POST | `/api/v1/order` | `{shopId, addressId, notes?}` |
| `markOrderReceived` | PATCH | `/api/v1/order/{id}/received` | |
| `cancelOrder` | PATCH | `/api/v1/order/{id}/cancel` | |
| `createVnpayPayment` | POST | `/api/v1/payment/orders/{id}/vnpay` | |
| `verifyVnpayPayment` | GET | `/api/v1/payment/vnpay/return` | query params |

### 6.6 UserAddressService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `listMyAddresses` | GET | `/api/v1/address` | |
| `createAddress` | POST | `/api/v1/address` | `{receiverName, receiverPhone, addressLine, city, district, ward, districtId?, wardCode?}` |
| `updateAddress` | PUT | `/api/v1/address/{id}` | `{...fields}` |
| `deleteAddress` | DELETE | `/api/v1/address/{id}` | |
| `setDefaultAddress` | PATCH | `/api/v1/address/{id}/default` | |

### 6.7 WalletService

| Method | HTTP | Endpoint |
|---|---|---|
| `getMyWallet` | GET | `/api/v1/wallet/me` |

**Luu y:** Chi co get wallet. Khong co withdraw/linkBank endpoint (README goc sai).

### 6.8 KycService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getMyKyc` | GET | `/api/v1/kyc/me` | |
| `submitKyc` | POST | `/api/v1/kyc/individual` | Multipart: `{idCardNumber, frontImage, backImage, selfieImage}` |

### 6.9 ChatService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getOrCreateConversation` | GET | `/api/v1/chat/conversation` | |
| `getMessages` | GET | `/api/v1/chat/{id}/messages` | `page, size` |
| `sendMessage` | POST | `/api/v1/chat/{id}/messages` | `{content}` |
| `markAsRead` | PATCH | `/api/v1/chat/{id}/messages/{msgId}/read` | |

### 6.10 ReportService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getMyReports` | GET | `/api/v1/report/me` | `status?` |
| `submitReport` | POST | `/api/v1/report` | `{reportType, reason, description?, targetId?, targetType?}` |
| `getReportById` | GET | `/api/v1/report/{id}` | |

### 6.11 ShippingService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getProvinces` | GET | `/api/v1/shipping/provinces` | |
| `getDistricts` | GET | `/api/v1/shipping/districts` | `provinceId` |
| `getWards` | GET | `/api/v1/shipping/wards` | `districtId` |
| `calculateFee` | POST | `/api/v1/shipping/fee` | `{from_district_id, from_ward_code, to_district_id, to_ward_code, weight, service_type_id?, insurance_value?}` |

### 6.12 ProfileService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `updateProfile` | PUT | `/api/v1/user/profile` | Multipart: `{fullName?, phoneNumber?, gender?, dateOfBirth?, avatarFile?}` |

### 6.13 ReviewService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `getProductReviews` | GET | `/api/v1/review/products/{productId}` | `page, size, rating?, hasImages?` |
| `getProductReviewStats` | GET | `/api/v1/review/products/{productId}/reviews/stats` | |
| `submitReview` | POST | `/api/v1/review/products/{productId}` | `{rating, comment?, images[]?}` (multipart) |

### 6.14 SellerService

| Method | HTTP | Endpoint | Body |
|---|---|---|---|
| `registerAsSeller` | POST | `/api/v1/seller/register` | `{shopName, shopDescription, businessEmail, businessPhone, businessAddress?}` |
| `getMyShop` | GET | `/api/v1/seller/me` | |
| `updateShop` | PUT | `/api/v1/seller/me` | `{shopName?, shopDescription?, ...}` |
| `getShopProducts` | GET | `/api/v1/seller/{shopId}/products` | `page, size` |
| `getShopOrders` | GET | `/api/v1/seller/{shopId}/orders` | `status?, page, size` |
| `updateOrderStatus` | PATCH | `/api/v1/seller/orders/{orderId}/status` | `{status}` |
| `replyToReview` | POST | `/api/v1/seller/reviews/{reviewId}/reply` | `{reply}` |

### 6.15 DashboardService

| Method | HTTP | Endpoint |
|---|---|---|
| `getSellerStatistics` | GET | `/api/v1/statistics/seller` |
| `getTopProducts` | GET | `/api/v1/order/shops/{shopId}/top-products` | `limit` |

### 6.16 PromotionService

| Method | HTTP | Endpoint |
|---|---|---|
| `getFlashSale` | GET | `/api/v1/promotions/flash-sale` |
| `getDeals` | GET | `/api/v1/promotions/deals` | `page, size` |
| `getBanners` | GET | `/api/v1/promotions/banners` |

---

## 7. Providers (State Management)

Tat ca su dung `flutter_riverpod` voi `StateNotifier` pattern hoac `FutureProvider`.

### 7.1 AuthNotifier (`auth_provider.dart`)

```dart
class AuthState { UserModel? user; String? token; bool isAuthenticated; bool accountVerified; bool isLoading; }
```

**Methods:**
- `_restoreSession()` - doc token + user tu secure storage khi app khoi dong
- `login(token, user)` - luu token + user
- `logout()` - xoa token, user, clear cart
- `updateUser(updatedUser)` - cap nhat user trong state
- `updateAccountVerified(value)` - cap nhat trang thai xac thuc

### 7.2 CartNotifier (`cart_provider.dart`)

```dart
class CartState { List<CartItem> items; int totalItems; double totalPrice; }
// Computed: totalItems, totalPrice
```

**Methods:**
- `setFromApi(CartApiResponse)` - load tu API
- `addItem(CartItem)`
- `updateQuantityById(id, quantity)`
- `updateQuantity(productId, quantity)`
- `removeById(id)`
- `removeItem(productId)`
- `clear()`

### 7.3 WalletProvider (`wallet_provider.dart`)

```dart
final walletServiceProvider = Provider<WalletService>((ref) => WalletService());
final walletProvider = FutureProvider.autoDispose<WalletModel>((ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getMyWallet();
});
```

### 7.4 ChatNotifier (`chat_provider.dart`)

```dart
class ChatState { Conversation? conversation; List<ChatMessage> messages; bool isLoading; bool isSending; String? error; }
```

**Methods:**
- `loadConversation()` - getOrCreate conversation + load messages
- `loadMoreMessages()` - pagination
- `sendMessage(content)` - gui tin nhan (optimistic)
- `clearError()`

### 7.5 DashboardProvider (`dashboard_provider.dart`)

```dart
final sellerStatisticsProvider = FutureProvider.autoDispose<SellerStatistics>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getSellerStatistics();
});
final topProductsProvider = FutureProvider.autoDispose.family<List<TopProduct>, int>((ref, shopId) async {
  return service.getTopProducts(shopId);
});
```

### 7.6 ProfileProvider (`profile_provider.dart`)

```dart
final profileUpdateProvider = StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<UserModel?>>((ref) {
  return ProfileUpdateNotifier(ref.watch(profileServiceProvider));
});

class ProfileUpdateNotifier {
  Future<UserModel> updateProfile({fullName?, phoneNumber?, gender?, dateOfBirth?, avatarPath?});
}
```

### 7.7 ThemeProvider (`theme_provider.dart`)

```dart
class ThemeState { ThemeMode mode; bool isDark; }

class ThemeNotifier {
  setTheme(ThemeMode mode);  // luu vao secure storage
  toggleTheme();              // dark <-> light
}
```

### 7.8 AuthServiceProvider (`auth_service_provider.dart`)

```dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
```

---

## 8. Screens

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

- **Banner Carousel:** CarouselSlider voi placeholder banners
- **Product Grid:** Grid 2 cot, pagination, pull-to-refresh
- **Recommendations:** Horizontal ListView (chi khi da login)
- **Quick View:** Long press product -> BottomSheet xem nhanh
- **Flash Sale:** Chuyen huong `/flash-sale`
- **Bottom Navigation:** 4 tabs - Trang chu, Don hang, Gio hang, Tai khoan
- **Cart Badge:** Hien so luong san pham trong gio hang

### 8.3 Flash Sale Screen (`/flash-sale`)

- Hien thi danh sach san pham Flash Sale tu API
- Countdown timer (neu co khuyen mai dang active)
- Chuyen huong sang ProductDetail khi bam

### 8.4 Product List Screen (`/products`)

- **Search:** TextField + API filter
- **Category Filter:** Load tu API, hien chip
- **Price Range Filter:** minPrice/maxPrice
- **Sort:** moi nhat, gia thap -> cao, gia cao -> thap
- **Pagination:** Infinite scroll
- **Filter Modal:** BottomSheet voi tat ca cac tuy chon loc

### 8.5 Product Detail Screen (`/products/:id`)

- **Image Gallery:** PageView carousel + thumbnail strip
- **Product Info:** ten, gia, danh muc, shop, so luong ton
- **Badges:** Chinh hang 100%, Mien phi ship, Bao hanh, Doi tra 7 ngay
- **Quantity Selector:** +/- buttons
- **Actions:** Them vao gio (chua login -> redirect login), Mua ngay
- **Description:** Scroll xuong xem mo ta
- **Reviews:** Thong ke (diem TB, thanh phan tram, loc theo rating), danh sach reviews
- **Similar Products:** Horizontal ListView

### 8.6 Cart Screen (`/cart`)

- **Auth Guard:** Chua login -> hien trang yeu cau dang nhap
- **Empty State:** Icon + text + nut "Tiep tuc mua sam"
- **Item Controls:** Tang/giam so luong, xoa
- **Checkout Button:** Tong tien + nut "Mua tu Shop nay" cho tung shop

### 8.7 Checkout Screen (`/checkout`)

- **Address Selection:** Load tu API, chon dia chi giao hang
- **No Address:** Hien thong bao + nut them dia chi moi
- **Shipping Fee Calculator:** Goi API tinh phi van chuyen khi chon dia chi
- **Order Note:** TextField cho ghi chu
- **Place Order:** Tao don hang COD hoac chuyen sang VNPay WebView

### 8.8 VNPay WebView Screen (`/checkout/vnpay`)

- Load VNPay URL trong WebView
- Lang nghe return URL (`vnp_ResponseCode`)
- Ma `00` = thanh cong -> chuyen `/payment-result`
- Ma khac = that bai -> hien message loi tuong ung
- Nut Quay ve trang chu / Xem don hang / Quay ve gio hang

### 8.9 Payment Result Screen (`/payment-result`)

- Hien thi ket qua thanh toan VNPay (thanh cong/that bai)
- Nut "Ve trang chu", "Xem don hang", "Quay ve gio hang"

### 8.10 Order List Screen (`/orders`)

- **Filter by Status:** PopupMenu voi cac trang thai
- **Order Card:** Ma don, ngay, trang thai (mau), so san pham, tong tien
- **Empty State:** "Chua co don hang nao"
- **Pull-to-refresh**

### 8.11 Order Detail Screen (`/orders/:id`)

- **Order Info:** Ma don, ngay dat, trang thai, phuong thuc thanh toan
- **Product List:** Hinh anh, ten, so luong, gia
- **Address:** Dia chi giao hang day du
- **Price Summary:** Tong tam tinh, phi van chuyen, tong cong
- **Actions:**
  - PENDING -> Nut "Huy don" (co confirm dialog)
  - SHIPPING -> Nut "Xac nhan da nhan hang" (co confirm dialog)
  - DELIVERED -> Nut "Danh gia" (chuyen `/submit-review`)
  - Da huy/hoan tien -> Chi xem

### 8.12 Submit Review Screen (`/submit-review`)

- Rating (1-5 sao) + binh luan + hinh anh (tuy chon)
- Gui len API

### 8.13 Profile Screen (`/profile`)

- **Header:** Avatar, ten, email
- **Menu Items:**
  - Don hang cua toi -> `/orders`
  - Dia chi giao hang -> `/addresses`
  - Xac thuc tai khoan (KYC) -> `/kyc`
  - Tin nhan ho tro -> `/chat`
  - Tro giup & Ho tro -> `/report`
  - Tro thanh nguoi ban -> `/seller/register`
- **Edit Icon:** Chuyen trang edit

### 8.14 Address List Screen (`/addresses`)

- **Empty State:** "Chua co dia chi nao"
- **Address Card:** Ten nguoi nhan, sdt, dia chi day du, badge "Mac dinh"
- **Actions:** Chinh sua, dat mac dinh, xoa (co confirm)
- **FAB:** Them dia chi moi -> `/addresses/add`

### 8.15 Address Form Screen (`/addresses/add` hoac `/addresses/edit`)

- **Fields:** Ten nguoi nhan, so dien thoai, Tinh/Quan/Phuong (Dropdown tu API shipping), duong, label
- **Validation:** Tat ca truong deu bat buoc, sdt VN format
- **Submit:** POST (tao moi) hoac PUT (cap nhat)

### 8.16 KYC Screen (`/kyc`)

- **Trang thai PENDING:** Icon dong ho xoay + thong bao "Dang cho xet duyet"
- **Trang thai APPROVED:** Icon check xanh + thong bao thanh cong
- **Trang thai REJECTED:** Icon X do + ly do tu choi + nut "Gui lai yeu cau"
- **Form (lan dau / gui lai):**
  - So CCCD (9 hoac 12 so, chi chua so)
  - 3 hinh anh: mat truoc CCCD, mat sau CCCD, anh chan dung (ImagePicker: camera/gallery)

### 8.17 Chat Screen (`/chat`)

- **Conversation:** getOrCreate conversation + load messages
- **Message View:** ChatBubble (USER=blue right, ADMIN/BOT=gray left), auto-scroll
- **ChatInput:** TextField + Send button, disabled khi dang gui

### 8.18 Report Screen (`/report`)

- **Tab 1:** "Dang xu ly" - danh sach bao cao chua giai quyet
- **Tab 2:** "Da giai quyet" - danh sach da xu ly
- **FAB:** Tao bao cao moi (loai: ORDER, PRODUCT, SELLER, REVIEW, OTHER + ly do + mo ta tuy chon)
- **Pull-to-refresh**

### 8.19 Seller Registration Screen (`/seller/register`)

- Form dang ky tro thanh nguoi ban
- Fields: shopName, shopDescription, businessEmail, businessPhone, businessAddress

### 8.20 Seller Dashboard Screen (`/seller/dashboard`)

- **Stat Cards:** Tong don, don cho xu ly, doanh thu, so san pham, khach hang, rating
- **Top Products:** ListView san pham ban chay
- **Orders:** Danh sach don hang theo trang thai

---

## 9. Widgets

### 9.1 ChatBubble (`lib/widgets/chat/chat_bubble.dart`)

- **USER:** Bong tin blue (AppColors.primary), canh phai
- **ADMIN/BOT:** Bong tin xam, canh trai
- **Hien thi:** noi dung, thoi gian (HH:mm)
- **Adaptive:** Ho tro dark/light mode

### 9.2 ChatInput (`lib/widgets/chat/chat_input.dart`)

- **TextField:** Multi-line (1-4 dong), border-radius 24, placeholder "Nhap tin nhan..."
- **Send Button:** Icon send, disabled khi `isSending=true`
- **Bottom padding:** Tinh den safe area cua thiet bi

### 9.3 ProductWidgets (`lib/screens/products/widgets/`)

- `product_filter_modal.dart` - BottomSheet loc san pham (category, price, sort)
- `product_quick_view.dart` - BottomSheet xem nhanh san pham

---

## 10. Routes

| Route | Screen | Auth |
|---|---|---|
| `/` | HomeScreen | - |
| `/login` | LoginScreen | Public |
| `/register` | RegisterScreen | Public |
| `/verify` | VerifyScreen | Public |
| `/products` | ProductListScreen | - |
| `/products/:id` | ProductDetailScreen | - |
| `/flash-sale` | FlashSaleScreen | - |
| `/cart` | CartScreen | Yes |
| `/checkout` | CheckoutScreen | Yes |
| `/checkout/vnpay` | VnpayWebViewScreen | Yes |
| `/payment-result` | PaymentResultScreen | Public |
| `/profile` | ProfileScreen | Yes |
| `/addresses` | AddressListScreen | Yes |
| `/addresses/add` | AddressFormScreen | Yes |
| `/addresses/edit` | AddressFormScreen | Yes |
| `/kyc` | KycScreen | Yes |
| `/orders` | OrderListScreen | Yes |
| `/orders/:id` | OrderDetailScreen | Yes |
| `/submit-review` | SubmitReviewScreen | Yes |
| `/chat` | ChatScreen | Yes |
| `/report` | ReportScreen | Yes |
| `/seller/register` | SellerRegistrationScreen | Yes |
| `/seller/dashboard` | SellerDashboardScreen | Yes (BUSINESS) |

---

## 11. API Endpoints

### 11.1 Auth

| Method | Endpoint | Mo ta |
|---|---|---|
| POST | `/api/v1/auth/login` | Dang nhap |
| POST | `/api/v1/auth/register` | Dang ky |
| POST | `/api/v1/auth/verify` | Xac thuc OTP |
| POST | `/api/v1/auth/resend-otp` | Gui lai OTP |

### 11.2 Product

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/product` | Danh sach san pham (paginated, filter, sort) |
| GET | `/api/v1/product/{id}` | Chi tiet san pham |
| GET | `/api/v1/recommendations` | San pham goi y |
| GET | `/api/v1/product/{id}/similar` | San pham tuong tu |

### 11.3 Cart

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/cart` | Lay gio hang |
| POST | `/api/v1/cart/items` | Them vao gio |
| POST | `/api/v1/cart/items/{id}/plus` | Tang so luong |
| POST | `/api/v1/cart/items/{id}/minus` | Giam so luong |
| DELETE | `/api/v1/cart/items/{id}` | Xoa khoi gio |

### 11.4 Order

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/order/me` | Danh sach don hang cua toi |
| GET | `/api/v1/order/{id}/me` | Chi tiet don hang cua toi |
| POST | `/api/v1/order` | Tao don hang |
| PATCH | `/api/v1/order/{id}/received` | Xac nhan da nhan hang |
| PATCH | `/api/v1/order/{id}/cancel` | Huy don |
| POST | `/api/v1/payment/orders/{id}/vnpay` | Tao thanh toan VNPay |
| GET | `/api/v1/payment/vnpay/return` | Xac nhan thanh toan VNPay |

### 11.5 Address

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/address` | Danh sach dia chi |
| POST | `/api/v1/address` | Tao dia chi moi |
| PUT | `/api/v1/address/{id}` | Cap nhat dia chi |
| DELETE | `/api/v1/address/{id}` | Xoa dia chi |
| PATCH | `/api/v1/address/{id}/default` | Dat dia chi mac dinh |

### 11.6 Wallet

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/wallet/me` | Lay thong tin vi |

### 11.7 KYC

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/kyc/me` | Lay KYC cua minh |
| POST | `/api/v1/kyc/individual` | Gui yeu cau KYC |

### 11.8 Chat

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/chat/conversation` | Tao/lay cuoc tro chuyen |
| GET | `/api/v1/chat/{id}/messages` | Lay tin nhan |
| POST | `/api/v1/chat/{id}/messages` | Gui tin nhan |
| PATCH | `/api/v1/chat/{id}/messages/{msgId}/read` | Danh dau da doc |

### 11.9 Report

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/report/me` | Lay danh sach bao cao cua toi |
| POST | `/api/v1/report` | Tao bao cao moi |
| GET | `/api/v1/report/{id}` | Chi tiet bao cao |

### 11.10 Review

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/review/products/{productId}` | Danh gia san pham |
| GET | `/api/v1/review/products/{productId}/reviews/stats` | Thong ke danh gia |
| POST | `/api/v1/review/products/{productId}` | Gui danh gia |

### 11.11 Seller

| Method | Endpoint | Mo ta |
|---|---|---|
| POST | `/api/v1/seller/register` | Dang ky nguoi ban |
| GET | `/api/v1/seller/me` | Lay thong tin shop cua toi |
| PUT | `/api/v1/seller/me` | Cap nhat thong tin shop |
| GET | `/api/v1/seller/{shopId}/products` | Danh sach san pham cua shop |
| GET | `/api/v1/seller/{shopId}/orders` | Don hang cua shop |
| PATCH | `/api/v1/seller/orders/{orderId}/status` | Cap nhat trang thai don |
| POST | `/api/v1/seller/reviews/{reviewId}/reply` | Tra loi danh gia |

### 11.12 Dashboard & Statistics

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/statistics/seller` | Thong ke cua nguoi ban |
| GET | `/api/v1/order/shops/{shopId}/top-products` | San pham ban chay |

### 11.13 Shipping

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/shipping/provinces` | Danh sach tinh/thanh |
| GET | `/api/v1/shipping/districts` | Danh sach quan/huyen |
| GET | `/api/v1/shipping/wards` | Danh sach phuong/xa |
| POST | `/api/v1/shipping/fee` | Tinh phi van chuyen |

### 11.14 Promotion

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/promotions/flash-sale` | Flash Sale |
| GET | `/api/v1/promotions/deals` | Deals |
| GET | `/api/v1/promotions/banners` | Banners |

### 11.15 Profile

| Method | Endpoint | Mo ta |
|---|---|---|
| PUT | `/api/v1/user/profile` | Cap nhat ho so (multipart) |

### 11.16 Category

| Method | Endpoint | Mo ta |
|---|---|---|
| GET | `/api/v1/category` | Lay danh sach danh muc |

---

## 12. Trang Thai Hoan Thien Theo Phase

| Phase | Ten | Status | Ngay |
|---|---|---|---|
| P0 | Project Setup | Hoan thanh | 2026-06-09 |
| P1 | Core Infrastructure | Hoan thanh | 2026-06-09 |
| P2 | Auth Screens | Hoan thanh | 2026-06-09 |
| P3 | Product Browsing | Hoan thanh | 2026-06-10 |
| P4 | Cart & Checkout | Hoan thanh | 2026-06-10 |
| P5 | Orders | Hoan thanh | 2026-06-09 |
| P6 | Profile & Wallet | Hoan thanh | 2026-06-10 |
| P7 | KYC & Address | Hoan thanh | 2026-06-10 |
| P8 | Flash Sale & Deals | Hoan thanh | 2026-06-10 |
| P9 | Chat & Report | Hoan thanh | 2026-06-10 |
| P10 | Business Dashboard | Hoan thanh | 2026-06-10 |
| P11 | Review System | Hoan thanh | 2026-06-10 |

**Tong hoan thien: ~95%**

---

## 13. Known Issues & Technical Notes

### 13.1 Cac van de can luu y

| # | Van de | Vi tri | Giai phap | Trang thai |
|---|---|---|---|---|
| 1 | Widget test chi la stub | test/widget_test.dart | Viet them unit test + widget test | CHUA FIX |
| 2 | Khong co `clearCart` endpoint | CartService | Chi xoa tung item, khong xoa ca gio | CANH BAO |
| 3 | Khong co withdraw/linkBank endpoint | WalletService | Chi get wallet, chua co withdraw/linkBank | CHUA FIX |
| 4 | Seller dashboard chi ho tro BUSINESS role | app_router.dart | USER/CUSTOMER bi redirect ve `/` | DA CHINH |
| 5 | Chat chi co 1 conversation | ChatService | `/chat/conversation` khong co param tao nhieu conversation | CANH BAO |

### 13.2 Route import paths

`app_router.dart` import cac screen tu `../../screens/...` - duong dan import tuong doi, can dam bao folder structure dung.

### 13.3 App Title

`app.dart` su dung title "AirPod Store". Neu doi ten app, cap nhat tai day.

### 13.4 Cart Provider - Khong co Sync

`CartProvider` luu cart locally. Khong co giai thich sync voi API sau khi addToCart. Can goi `getCart` de refresh sau khi thay doi.

---

## 14. Luong Hoat Dong Chinh

### 14.1 Luong Auth - Register -> Verify -> Login

```
RegisterScreen
  -> POST /api/v1/auth/register
  -> /verify?email=...

VerifyScreen
  -> POST /api/v1/auth/verify
  -> /login

LoginScreen
  -> POST /api/v1/auth/login -> {token, user}
  -> Luu {access_token, auth_user} vao flutter_secure_storage
  -> / (HomeScreen)
```

### 14.2 Luong Mua Hang A-Z

```
HomeScreen
  -> /products
  -> /products/:id (ProductDetailScreen)
  -> [Them vao gio] -> POST /api/v1/cart/items
  -> /cart (CartScreen)
  -> [Mua tu Shop nay] -> /checkout?shopId=...
  -> [Chon dia chi] -> POST /api/v1/shipping/fee (tinh phi)
  -> [COD] -> POST /api/v1/order -> /orders
  -> [VNPay] -> POST /api/v1/payment/orders/{id}/vnpay -> /checkout/vnpay
    -> VNPay WebView -> Return URL voi vnp_ResponseCode
    -> /payment-result -> /orders
```

### 14.3 Luong Dia Chi & Shipping

```
CheckoutScreen
  -> GET /api/v1/address (lay ds dia chi)
  -> [Chon dia chi] -> AddressListScreen -> AddressFormScreen
  -> [Submit dia chi] -> POST /api/v1/address
  -> [Chon dia chi xong] -> POST /api/v1/shipping/fee
  -> POST /api/v1/order
```

### 14.4 Luong Seller

```
ProfileScreen
  -> /seller/register -> SellerRegistrationScreen
  -> POST /api/v1/seller/register
  -> /seller/dashboard -> SellerDashboardScreen
  -> GET /api/v1/statistics/seller
  -> GET /api/v1/order/shops/{shopId}/orders
  -> GET /api/v1/seller/{shopId}/products
```

---

## 15. Cac File Chinh Yeu

| STT | File | Mo ta |
|---|---|---|
| 1 | `lib/main.dart` | Entry point, load .env, wrap ProviderScope |
| 2 | `lib/app.dart` | MaterialApp.router, theme light/dark, router config |
| 3 | `lib/core/router/app_router.dart` | GoRouter, 19 routes, auth guard |
| 4 | `lib/core/api/api_client.dart` | Dio singleton instance |
| 5 | `lib/core/api/api_interceptors.dart` | Bearer token interceptor |
| 6 | `lib/providers/auth_provider.dart` | Auth state + session management |
| 7 | `lib/providers/cart_provider.dart` | Cart state + local management |
| 8 | `lib/providers/chat_provider.dart` | Chat state + messages |
| 9 | `lib/providers/wallet_provider.dart` | Wallet FutureProvider |
| 10 | `lib/providers/dashboard_provider.dart` | Seller statistics + top products |
| 11 | `lib/providers/profile_provider.dart` | Profile update notifier |
| 12 | `lib/providers/theme_provider.dart` | Theme mode management |
| 13 | `lib/data/services/auth_service.dart` | Login/register/verify |
| 14 | `lib/data/services/product_service.dart` | Product CRUD + recommendations |
| 15 | `lib/data/services/cart_service.dart` | Cart CRUD + quantity management |
| 16 | `lib/data/services/order_service.dart` | Full order lifecycle + VNPay |
| 17 | `lib/data/services/shipping_service.dart` | Province/District/Ward + fee calculation |
| 18 | `lib/data/services/seller_service.dart` | Seller registration + shop management |
| 19 | `lib/data/services/dashboard_service.dart` | Seller statistics + top products |
| 20 | `lib/data/services/promotion_service.dart` | Flash sale + deals + banners |
| 21 | `lib/data/services/review_service.dart` | Reviews + stats + submit |
| 22 | `lib/data/services/kyc_service.dart` | KYC submission |
| 23 | `lib/data/services/chat_service.dart` | Chat + messages |
| 24 | `lib/data/services/report_service.dart` | Report CRUD |
| 25 | `lib/screens/home/home_screen.dart` | Trang chu + banners + product grid |
| 26 | `lib/screens/products/product_detail_screen.dart` | Chi tiet san pham + reviews |
| 27 | `lib/screens/user/checkout/checkout_screen.dart` | Thanh toan + VNPay |
| 28 | `lib/screens/user/orders/order_list_screen.dart` | Danh sach don hang |
| 29 | `lib/screens/user/profile/profile_screen.dart` | Profile + menu |
| 30 | `lib/screens/user/seller/seller_dashboard_screen.dart` | Seller dashboard |
| 31 | `pubspec.yaml` | 16 dependencies |
| 32 | `.env` | API_BASE_URL=http://localhost:8080 |
| 33 | `README.md` | Tai lieu phat trien chi tiet |

---

*Tai lieu nay duoc cap nhat chinh xac theo code thuc te cua project Ecommerce Mobile (Flutter).*
*Tong so file: 87. Tong so code: ~15,699 dong Dart.*
*Cap nhat lan cuoi: 2026-06-11*
