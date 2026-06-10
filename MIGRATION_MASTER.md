# MIGRATION_MASTER.md
# Flutter Migration — Ecommerce FE (React → Flutter)
# ⚠️ Cursor: Đọc file này 1 lần duy nhất khi bắt đầu project. Sau đó chỉ đọc README.md.

---

## A. Hệ thống gốc (React)

**Stack:** React 19 + Vite + TailwindCSS + Zustand + Axios + STOMP WebSocket  
**Backend:** REST API tại `http://localhost:8080`, JWT Bearer auth, VNPay payment  

### Roles
| Role | Quyền |
|---|---|
| Guest | Browse sản phẩm, xem deals |
| USER | Mua hàng, cart, order, profile, wallet, marketplace |
| BUSINESS | Quản lý shop, sản phẩm, đơn hàng |
| ADMIN | Dashboard, requests, escrows, commissions, live chat |

### Toàn bộ màn hình React → Flutter
| React | Flutter Screen | Role |
|---|---|---|
| `Home.jsx` | `HomeScreen` | Guest |
| `Products.jsx` | `ProductListScreen` | Guest |
| `ProductDetail.jsx` | `ProductDetailScreen` | Guest |
| `Deals.jsx` | `DealsScreen` | Guest |
| `Marketplace.jsx` | `MarketplaceScreen` | Guest |
| `Login.jsx` | `LoginScreen` | Guest |
| `Register.jsx` | `RegisterScreen` | Guest |
| `Verify.jsx` | `VerifyScreen` | Guest |
| `Cart.jsx` | `CartScreen` | USER |
| `Checkout.jsx` | `CheckoutScreen` | USER |
| `PaymentResult.jsx` | `PaymentResultScreen` | USER |
| `orders/MyOrders.jsx` | `MyOrdersScreen` | USER |
| `orders/OrderDetail.jsx` | `OrderDetailScreen` | USER |
| `Profile.jsx` | `ProfileScreen` | USER |
| `profile/ProfileWallet.jsx` | `WalletScreen` | USER |
| `SellerRegister.jsx` | `SellerRegisterScreen` | USER |
| `kyc/Kyc.jsx` | `KycScreen` | USER |
| `OfferDetails.jsx` | `OfferDetailsScreen` | USER |
| `ReportCreate.jsx` | `ReportCreateScreen` | USER |
| `business/BusinessDashboard.jsx` | `BusinessDashboardScreen` | BUSINESS |
| `business/ShopOrders.jsx` | `ShopOrdersScreen` | BUSINESS |
| `business/ShopOrderDetail.jsx` | `ShopOrderDetailScreen` | BUSINESS |
| `admin/AdminDashboard.jsx` | `AdminDashboardScreen` | ADMIN |
| `admin/AdminRequests.jsx` | `AdminRequestsScreen` | ADMIN |
| `admin/AdminRequestDetail.jsx` | `AdminRequestDetailScreen` | ADMIN |
| `admin/AdminOrders.jsx` | `AdminOrdersScreen` | ADMIN |
| `admin/AdminOrderDetail.jsx` | `AdminOrderDetailScreen` | ADMIN |
| `admin/AdminEscrows.jsx` | `AdminEscrowsScreen` | ADMIN |
| `admin/AdminWalletLookup.jsx` | `AdminWalletLookupScreen` | ADMIN |
| `admin/AdminCommissions.jsx` | `AdminCommissionsScreen` | ADMIN |
| `admin/AdminLiveChat.jsx` | `AdminLiveChatScreen` | ADMIN |
| `admin/AdminShopRanking.jsx` | `AdminShopRankingScreen` | ADMIN |
| `admin/AdminPlatformWallet.jsx` | `AdminPlatformWalletScreen` | ADMIN |

---

## B. Dependency Mapping (JS → Dart)

| JS/React | Flutter | pubspec |
|---|---|---|
| `axios` | `dio` | `dio: ^5.7.0` |
| `zustand` + persist | `flutter_riverpod` + `flutter_secure_storage` | `flutter_riverpod: ^2.5.0` |
| `react-router-dom` | `go_router` | `go_router: ^14.0.0` |
| `react-hook-form` | `reactive_forms` | `reactive_forms: ^17.0.0` |
| `react-hot-toast` | `fluttertoast` | `fluttertoast: ^8.2.8` |
| `framer-motion` | `flutter_animate` | `flutter_animate: ^4.5.0` |
| `@stomp/stompjs` + `sockjs-client` | `stomp_dart_client` | `stomp_dart_client: ^2.0.0` |
| `jwt-decode` | `dart_jsonwebtoken` | `dart_jsonwebtoken: ^2.8.0` |
| `react-slick` | `carousel_slider` | `carousel_slider: ^5.0.0` |
| `CameraCapture.jsx` | `image_picker` | `image_picker: ^1.1.2` |
| VNPay redirect | `webview_flutter` | `webview_flutter: ^4.8.0` |
| `VITE_API_BASE_URL` | `flutter_dotenv` | `flutter_dotenv: ^5.2.1` |
| `clsx`/tailwind | Flutter ThemeData | — |

---

## C. Logic chuyển đổi quan trọng

### C1. Auth State (useAuthStore.js → auth_provider.dart)
```
Zustand state: { user, token, isAuthenticated, accountVerified }
Actions: login(token, user), logout(), updateUser(), updateAccountVerified()
Persist: localStorage

→ Dart: StateNotifier<AuthState> với Riverpod
→ Token lưu flutter_secure_storage (KHÔNG dùng SharedPreferences cho token)
→ User info persist SharedPreferences
→ Decode JWT: getAccountVerified(token) → jwt_utils.dart
```

### C2. API Client (lib/axios.js → api_client.dart)
```
baseURL: VITE_API_BASE_URL || 'http://localhost:8080'
interceptors request: thêm Authorization: Bearer <token>
interceptors response: 401 → clear token + redirect /login

→ Dart: Dio với BaseOptions + InterceptorsWrapper
→ Token đọc từ flutter_secure_storage
→ 401 handler: authNotifier.logout() + GoRouter.go('/login')
```

### C3. Navigation Guard (ProtectedRoute.jsx → GoRouter redirect)
```
Props: requireAuth, allowedRoles: ['BUSINESS'] | ['ADMIN']

→ GoRouter redirect callback:
  if (!auth.isAuthenticated) return '/login';
  if (route.requiresRole && user.role != requiredRole) return '/';
```

### C4. WebSocket Chatbot + LiveChat
```
ChatbotButton.jsx + AdminLiveChat.jsx:
  dùng @stomp/stompjs over SockJS

→ StompClient(webSocketUrl: 'ws://localhost:8080/ws')
→ StreamController<ChatMessage> để push message vào UI
```

### C5. VNPay Payment
```
Checkout.jsx → POST /api/payment → nhận vnpay_url → window.location = url

→ Flutter: webview_flutter mở vnpay_url trong WebViewWidget
→ NavigationDelegate.onNavigationRequest: detect redirect về /vnpay_return
→ Đóng WebView → GoRouter.go('/payment/vnpay_return?...')
```

---

## D. Cấu trúc thư mục Flutter (chuẩn)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   └── api_interceptors.dart
│   ├── constants/
│   │   └── app_colors.dart
│   ├── router/
│   │   └── app_router.dart
│   └── utils/
│       ├── jwt_utils.dart
│       └── order_status.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── cart_model.dart
│   │   ├── order_model.dart
│   │   └── wallet_model.dart
│   └── services/
│       ├── auth_service.dart
│       ├── product_service.dart
│       ├── cart_service.dart
│       ├── order_service.dart
│       ├── kyc_service.dart
│       ├── review_service.dart
│       ├── report_service.dart
│       ├── seller_service.dart
│       └── wallet_service.dart
├── providers/
│   ├── auth_provider.dart
│   └── cart_provider.dart
├── screens/
│   ├── public/
│   ├── user/
│   ├── business/
│   └── admin/
└── widgets/
    ├── common/
    ├── product/
    ├── chat/
    └── marketplace/
```

---

## E. pubspec.yaml đầy đủ

```yaml
name: ecommerce_mobile
environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
  flutter_riverpod: ^2.5.0
  dio: ^5.7.0
  shared_preferences: ^2.3.0
  flutter_secure_storage: ^9.2.2
  dart_jsonwebtoken: ^2.8.0
  reactive_forms: ^17.0.0
  flutter_animate: ^4.5.0
  carousel_slider: ^5.0.0
  cached_network_image: ^3.3.1
  fluttertoast: ^8.2.8
  stomp_dart_client: ^2.0.0
  image_picker: ^1.1.2
  webview_flutter: ^4.8.0
  flutter_dotenv: ^5.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

---

## F. Quy tắc cho Cursor

1. **Mỗi lần bắt đầu session mới → chỉ đọc README.md**, không đọc lại file này
2. **Sau khi hoàn thành 1 phase → cập nhật README.md** theo template trong README.md
3. **Không dùng Flame engine** — dùng CustomPainter cho mọi animation 2D
4. **Không dùng Provider/Bloc** — chỉ dùng Riverpod
5. **Token JWT** → flutter_secure_storage, không bao giờ SharedPreferences
6. **Form phức tạp** (Register, Checkout, SellerRegister) → reactive_forms
7. **Form đơn giản** → TextEditingController là đủ

