import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme.dart';
import 'jual/jual_page.dart';
import 'katalog/katalog_page.dart';
import 'keranjang/keranjang_page.dart';
import 'pesanan/pesanan_page.dart';
import 'profil/profil_page.dart';

/// Halaman utama setelah login: 5 tab di navigasi bawah.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _pages = [
    KatalogPage(),
    KeranjangPage(),
    JualPage(),
    PesananPage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        Widget ikon(IconData i, int badge, {bool aktif = false}) {
          final icon = Icon(i,
              color: aktif ? AppColors.onYellow : const Color(0xFFF3D9D4));
          if (badge == 0) return icon;
          return Badge(
            label: Text('$badge'),
            backgroundColor: AppColors.yellow,
            textColor: AppColors.onYellow,
            child: icon,
          );
        }

        NavigationDestination item(
            IconData off, IconData on, String label, int badge) {
          return NavigationDestination(
            icon: ikon(off, badge),
            selectedIcon: ikon(on, badge, aktif: true),
            label: label,
          );
        }

        return Scaffold(
          body: IndexedStack(index: app.tab, children: _pages),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.resolveWith((s) {
                final on = s.contains(MaterialState.selected);
                return TextStyle(
                  fontSize: 12,
                  fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                  color: on ? AppColors.yellow : const Color(0xFFF3D9D4),
                );
              }),
            ),
            child: NavigationBar(
              backgroundColor: AppColors.brown,
              indicatorColor: AppColors.yellow,
              selectedIndex: app.tab,
              onDestinationSelected: app.setTab,
              destinations: [
                item(Icons.storefront_outlined, Icons.storefront, 'Katalog', 0),
                item(Icons.shopping_cart_outlined, Icons.shopping_cart,
                    'Keranjang', app.cart.length),
                item(Icons.add_circle_outline, Icons.add_circle, 'Jual', 0),
                item(Icons.local_shipping_outlined, Icons.local_shipping,
                    'Pesanan', app.pesananAktif),
                item(Icons.person_outline, Icons.person, 'Profil', 0),
              ],
            ),
          ),
        );
      },
    );
  }
}
