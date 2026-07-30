import 'package:flutter/material.dart';

/// Ekranların (özellikle game_screen) bir üstteki route pop'landığında
/// tekrar görünür olduklarını (didPopNext) anlayabilmesi için kullanılan
/// paylaşılan RouteObserver. router.dart'ta GoRouter'a `observers` olarak
/// verilir; ilgili State sınıfları `RouteAware` mixin'i ile buna abone olur.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();