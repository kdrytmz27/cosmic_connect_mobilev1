// // lib/screens/premium_screen.dart - GÜNCELLENMİŞ TAM HALİ

// import 'dart:async';
// import 'dart:io'; // Platformu belirlemek için eklendi
// import 'package:cosmic_connect_mobile/services/api_service.dart'; // ApiService import edildi
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';

// class PremiumScreen extends StatefulWidget {
//   const PremiumScreen({super.key});

//   @override
//   State<PremiumScreen> createState() => _PremiumScreenState();
// }

// class _PremiumScreenState extends State<PremiumScreen> {
//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   late StreamSubscription<List<PurchaseDetails>> _subscription;

//   final Set<String> _kProductIds = {'aylik_premium'};

//   List<ProductDetails> _products = [];
//   bool _isAvailable = false;
//   bool _isLoading = true;
//   bool _isVerifying = false; // YENİ: Doğrulama işlemi için yüklenme durumu

//   @override
//   void initState() {
//     super.initState();
//     final Stream<List<PurchaseDetails>> purchaseUpdated =
//         _inAppPurchase.purchaseStream;
//     _subscription = purchaseUpdated.listen((purchaseDetailsList) {
//       _listenToPurchaseUpdated(purchaseDetailsList);
//     }, onDone: () {
//       _subscription.cancel();
//     }, onError: (error) {
//       // Hata yönetimi
//     });

//     initStoreInfo();
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }

//   Future<void> initStoreInfo() async {
//     final bool isAvailable = await _inAppPurchase.isAvailable();
//     if (!isAvailable) {
//       setState(() => _isLoading = false);
//       return;
//     }

//     final ProductDetailsResponse productDetailResponse =
//         await _inAppPurchase.queryProductDetails(_kProductIds);

//     if (mounted) {
//       setState(() {
//         _products = productDetailResponse.productDetails;
//         _isAvailable = true;
//         _isLoading = false;
//       });
//     }
//   }

//   // YENİ: Satın almayı backend'de doğrulayan fonksiyon
//   Future<void> _verifyAndGrantPremium(PurchaseDetails purchaseDetails) async {
//     if (_isVerifying) {
//       return; // Zaten bir doğrulama işlemi varsa tekrar çalıştırma
//     }

//     setState(() => _isVerifying = true);

//     // Satın alma kanıtını al
//     final String purchaseToken =
//         purchaseDetails.verificationData.serverVerificationData;
//     final String platform = Platform.isAndroid ? 'android' : 'ios';

//     final bool success = await ApiService().verifyPurchase(
//       platform: platform,
//       productId: purchaseDetails.productID,
//       purchaseToken: purchaseToken,
//     );

//     if (!mounted) return; // Sayfa kapandıysa işlem yapma

//     setState(() => _isVerifying = false);

//     if (success) {
//       if (!mounted) return; // widget aktif değilse çık

//       await showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Ödeme Başarılı!'),
//           content: const Text(
//               'Premium üyeliğiniz başarıyla aktif edildi. Tüm özellikleri şimdi kullanabilirsiniz.'),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Harika!'))
//           ],
//         ),
//       );

//       if (!mounted) return; // dialog kapandıktan sonra da kontrol et

//       Navigator.of(context).pop(); // Premium ekranını kapat
//     } else {
//       // Başarısız olursa
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//                 'Satın alma doğrulanamadı. Lütfen destek ile iletişime geçin.')),
//       );
//     }
//   }

//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//     for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         // Ödeme beklemede...
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           // Hata oldu...
//         } else if (purchaseDetails.status == PurchaseStatus.purchased ||
//             purchaseDetails.status == PurchaseStatus.restored) {
//           // Satın alma başarılı! Backend'e doğrulatma işlemini başlat.
//           _verifyAndGrantPremium(purchaseDetails);
//         }
//         if (purchaseDetails.pendingCompletePurchase) {
//           _inAppPurchase.completePurchase(purchaseDetails);
//         }
//       }
//     }
//   }

//   void _buyProduct(ProductDetails product) {
//     final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
//     _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Premium\'a Yükselt')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : !_isAvailable || _products.isEmpty
//               ? const Center(child: Text('Premium ürünler şu an mevcut değil.'))
//               : _buildProductList(),
//     );
//   }

//   Widget _buildProductList() {
//     final ProductDetails product = _products.first;

//     return Center(
//       child: Card(
//         margin: const EdgeInsets.all(24.0),
//         elevation: 4,
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(product.title,
//                   style: Theme.of(context).textTheme.headlineSmall),
//               const SizedBox(height: 8),
//               Text(product.description,
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyMedium),
//               const SizedBox(height: 24),
//               Text(product.price,
//                   style: Theme.of(context)
//                       .textTheme
//                       .headlineMedium
//                       ?.copyWith(color: Colors.purple)),
//               const SizedBox(height: 24),
//               // Yükleme sırasında butonu devre dışı bırak
//               _isVerifying
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: () => _buyProduct(product),
//                       child: const Text('Hemen Satın Al'),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
