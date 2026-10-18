import 'package:flutter/material.dart';

enum ChronoPage { tracker, report }

class ChronoShell extends StatelessWidget {
  const ChronoShell({required this.page, required this.child, super.key});

  final ChronoPage page;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (isWide) _Sidebar(page: page),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(compact: !isWide),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: page == ChronoPage.tracker ? 0 : 1,
                  onDestinationSelected: (index) => _navigate(context, index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.timer_outlined),
                      label: 'Rastreador',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      label: 'Diário',
                    ),
                  ],
                ),
        );
      },
    );
  }

  static void _navigate(BuildContext context, int index) {
    final route = index == 0 ? '/' : '/report';
    if ((index == 0 && ModalRoute.of(context)?.settings.name == null) ||
        (index == 1 && ModalRoute.of(context)?.settings.name == '/report')) {
      return;
    }
    Navigator.pushReplacementNamed(context, route);
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.page});

  final ChronoPage page;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 238,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF252E43))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              _BrandMark(),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perceirometro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'v1.0.0  •  pro',
                    style: TextStyle(color: Color(0xFF9298AD), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF252E43)),
          const SizedBox(height: 12),
          _NavItem(
            icon: Icons.timer_outlined,
            label: 'Rastreador',
            selected: page == ChronoPage.tracker,
            route: '/',
          ),
          _NavItem(
            icon: Icons.calendar_month_outlined,
            label: 'Diário de Tarefas',
            selected: page == ChronoPage.report,
            route: '/report',
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 32),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF252E43))),
      ),
      child: Row(
        children: [
          const _BrandMark(),
          const SizedBox(width: 10),
          const Text(
            'Terceirometro',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notificações',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Ajuda',
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFE4E9FF) : const Color(0xFF9298AD);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? const Color(0xFF5142DE) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => Navigator.pushReplacementNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: TextStyle(color: color)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF5142DE),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(Icons.timer_outlined, color: Color(0xFFE4E9FF)),
    );
  }
}
