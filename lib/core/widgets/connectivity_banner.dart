import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../services/connectivity_service.dart';
import '../theme/app_theme.dart';

/// Envolva qualquer Scaffold com este widget para mostrar um banner
/// quando o dispositivo perder a conexão com a internet.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  bool _online = true;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    // Verifica estado inicial
    ConnectivityService.isOnline().then((online) {
      if (!mounted) return;
      setState(() => _online = online);
      if (!online) _ctrl.forward();
    });

    // Escuta mudanças
    ConnectivityService.onlineStream.listen((online) {
      if (!mounted) return;
      setState(() => _online = online);
      if (online) {
        _ctrl.reverse();
      } else {
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner animado
        SizeTransition(
          sizeFactor: _anim,
          child: Material(
            color: AppColors.criticidadeAlta,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_outlined,
                        color: Colors.white, size: 18),
                    const Gap(8),
                    const Expanded(
                      child: Text(
                        'Sem conexão — verifique sua internet',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
