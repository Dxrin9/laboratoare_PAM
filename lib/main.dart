import 'package:flutter/material.dart';

void main() {
  runApp(const AplicatieCursValutar());
}

class Moneda {
  final String cod;
  final String steag;
  final String nume;
  final double cursMdl;

  const Moneda(this.cod, this.steag, this.nume, this.cursMdl);
}

const List<Moneda> monede = [
  Moneda('MDL', '🇲🇩', 'Leu moldovenesc', 1.0),
  Moneda('EUR', '🇪🇺', 'Euro', 20.1931),
  Moneda('USD', '🇺🇸', 'Dolar american', 17.7553),
  Moneda('GBP', '🇬🇧', 'Liră sterlină', 23.5397),
  Moneda('RON', '🇷🇴', 'Leu românesc', 3.8253),
  Moneda('UAH', '🇺🇦', 'Grivnă ucraineană', 0.3957),
];

Moneda _dupaCod(String cod) => monede.firstWhere((m) => m.cod == cod);

class AplicatieCursValutar extends StatelessWidget {
  const AplicatieCursValutar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Convertor Valutar',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
      ),
      home: const EcranConvertor(),
    );
  }
}

class EcranConvertor extends StatefulWidget {
  const EcranConvertor({super.key});

  @override
  State<EcranConvertor> createState() => _EcranConvertorState();
}

class _EcranConvertorState extends State<EcranConvertor> {
  final TextEditingController _sumaController =
  TextEditingController(text: '100');

  Moneda _sursa = _dupaCod('MDL');
  Moneda _dest = _dupaCod('EUR');

  // Pentru animația butonului de schimb
  double _rotatie = 0;

  @override
  void dispose() {
    _sumaController.dispose();
    super.dispose();
  }


  double? get _suma {
    final text = _sumaController.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return 0;
    return double.tryParse(text);
  }

  double get _rezultat {
    final suma = _suma ?? 0;
    // Trecem prin MDL: sumă -> MDL -> moneda destinație
    return suma * _sursa.cursMdl / _dest.cursMdl;
  }

  double get _cursDirect => _sursa.cursMdl / _dest.cursMdl;

  void _inverseaza() {
    setState(() {
      final temp = _sursa;
      _sursa = _dest;
      _dest = temp;
      _rotatie += 0.5;
    });
  }

  String _formateazaSuma(double valoare) {
    final parti = valoare.toStringAsFixed(2).split('.');
    final intreg = parti[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ' ',
    );
    return '$intreg,${parti[1]}';
  }

  String _formateazaCurs(double valoare) =>
      valoare.toStringAsFixed(4).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eroare = _suma == null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.primary.withOpacity(0.75),
              scheme.tertiary.withOpacity(0.85),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Convertor valutar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cursuri valabile la 29.09.2026',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    _cardInput(scheme, eroare),
                    const SizedBox(height: 16),
                    _cardRezultat(scheme, eroare),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Cardul cu suma + selectoare monede ----------

  Widget _cardInput(ColorScheme scheme, bool eroare) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _sumaController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Suma',
              errorText: eroare ? 'Introduceți un număr valid' : null,
              prefixIcon: const Icon(Icons.payments_outlined),
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _selectorMoneda(
            eticheta: 'Din',
            valoare: _sursa,
            laSchimbare: (m) => setState(() => _sursa = m),
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          Center(
            child: AnimatedRotation(
              turns: _rotatie,
              duration: const Duration(milliseconds: 300),
              child: IconButton.filled(
                onPressed: _inverseaza,
                tooltip: 'Inversează monedele',
                icon: const Icon(Icons.swap_vert_rounded),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _selectorMoneda(
            eticheta: 'În',
            valoare: _dest,
            laSchimbare: (m) => setState(() => _dest = m),
            scheme: scheme,
          ),
        ],
      ),
    );
  }

  Widget _selectorMoneda({
    required String eticheta,
    required Moneda valoare,
    required ValueChanged<Moneda> laSchimbare,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              eticheta,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: valoare.cod,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                items: monede.map((m) {
                  return DropdownMenuItem<String>(
                    value: m.cod,
                    child: Row(
                      children: [
                        Text(m.steag, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Text(
                          m.cod,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            m.nume,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (cod) {
                  if (cod != null) laSchimbare(_dupaCod(cod));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Cardul cu rezultat ----------

  Widget _cardRezultat(ColorScheme scheme, bool eroare) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rezultat',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: FittedBox(
              key: ValueKey('${_rezultat}_${_dest.cod}_$eroare'),
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                eroare
                    ? '—'
                    : '${_formateazaSuma(_rezultat)} ${_dest.cod}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_flat, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                '1 ${_sursa.cod} = ${_formateazaCurs(_cursDirect)} ${_dest.cod}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}