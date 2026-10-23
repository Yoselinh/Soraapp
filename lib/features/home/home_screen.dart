import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: SoraColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola 👋', style: tt.bodyMedium),
                      Text(
                        'SORA',
                        style: tt.displayMedium?.copyWith(
                          color: SoraColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: SoraColors.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, color: SoraColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Diseña tu estilo.\nTú lo imaginas, SORA lo confecciona.',
                style: tt.bodyLarge?.copyWith(height: 1.5, color: const Color(0xFF5D4038)),
              ),
              const SizedBox(height: 32),

              // Stat cards
              Row(
                children: [
                  _StatCard(value: '2,400+', label: 'Diseños\ncreados'),
                  const SizedBox(width: 12),
                  _StatCard(value: '850+', label: 'Clientes\nsatisfechos'),
                  const SizedBox(width: 12),
                  _StatCard(value: '6', label: 'Talleres\nasociados'),
                ],
              ),
              const SizedBox(height: 32),

              // CTA buttons
              FilledButton.icon(
                onPressed: () => context.go(SoraRoutes.disenador),
                icon: const Icon(Icons.edit_note),
                label: const Text('Comenzar a diseñar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go(SoraRoutes.talleres),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Explorar talleres de confección'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go(SoraRoutes.pedidos),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Ver mis pedidos'),
              ),
              const SizedBox(height: 36),

              // Prendas populares
              Text('Prendas populares', style: tt.headlineSmall),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: const [
                  _PrendaCard(tipo: TipoPrenda.casaca, emoji: '🧥', nombre: 'Casaca', desde: 'Desde S/.45'),
                  _PrendaCard(tipo: TipoPrenda.polo, emoji: '👕', nombre: 'Polo', desde: 'Desde S/.35'),
                  _PrendaCard(tipo: TipoPrenda.vestido, emoji: '👗', nombre: 'Vestido', desde: 'Desde S/.42'),
                  _PrendaCard(tipo: TipoPrenda.pantalon, emoji: '👖', nombre: 'Pantalón', desde: 'Desde S/.38'),
                  _PrendaCard(tipo: TipoPrenda.camisa, emoji: '👔', nombre: 'Camisa', desde: 'Desde S/.36'),
                  _PrendaCard(tipo: TipoPrenda.short, emoji: '🩳', nombre: 'Short', desde: 'Desde S/.30'),
                  _PrendaCard(tipo: TipoPrenda.falda, emoji: '💃', nombre: 'Falda', desde: 'Desde S/.34'),
                  _PrendaCard(tipo: TipoPrenda.uniforme, emoji: '🦺', nombre: 'Uniforme', desde: 'Desde S/.40'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: SoraColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SoraColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: SoraColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8D7060),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrendaCard extends StatelessWidget {
  final TipoPrenda tipo;
  final String emoji;
  final String nombre;
  final String desde;

  const _PrendaCard({
    required this.tipo,
    required this.emoji,
    required this.nombre,
    required this.desde,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final prov = context.read<DisenadorProvider>();
        prov.reiniciar();
        prov.actualizarDiseno(prov.diseno.copyWith(prenda: tipo));
        context.go(SoraRoutes.disenador);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SoraColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SoraColors.cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: SoraColors.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desde,
              style: const TextStyle(
                fontSize: 12,
                color: SoraColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
