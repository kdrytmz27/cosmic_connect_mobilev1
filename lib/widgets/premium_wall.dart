// // lib/widgets/premium_wall.dart DOSYASININ TAM İÇERİĞİ

// import 'package:flutter/material.dart';
// // YENİ: Oluşturduğumuz premium ekranını import ediyoruz.
// import 'package:cosmic_connect_mobile/screens/premium_screen.dart';

// class PremiumWall extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String description;

//   const PremiumWall({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // ignore: deprecated_member_use
//             Icon(icon, size: 64, color: Colors.purple.withOpacity(0.5)),
//             const SizedBox(height: 24),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               description,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//               // DEĞİŞİKLİK: onPressed artık SnackBar göstermek yerine
//               // PremiumScreen'e yönlendirme yapıyor.
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const PremiumScreen(),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.star),
//               label: const Text('Premium\'a Yükselt'),
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
