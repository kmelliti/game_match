import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config_file.dart';

class ColorEntry {
  final Color color;
  final String label;

  const ColorEntry({required this.color, required this.label});

  String get hexString {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  String get flutterCode =>
      "const Color(0x${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()})";
}

// ─── Page ────────────────────────────────────────────────────────────────────

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  final List<ColorEntry?> _colors = [];
  final TextEditingController _labelController = TextEditingController();

  int _r = 108, _g = 99, _b = 255, _a = 255;

  Color get _currentColor => Color.fromARGB(_a, _r, _g, _b);

  void _addColor() {
    final label = _labelController.text.trim().isEmpty
        ? 'color${_colors.length + 1}'
        : _labelController.text.trim();

    setState(() {
      _colors.add(ColorEntry(color: _currentColor, label: label));
      _labelController.clear();
    });
  }

  void _removeColor(int index) {
    setState(() => _colors.removeAt(index));
  }



  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Picker'),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        height: 100,
        padding: EdgeInsets.all(20),
        child: ElevatedButton(onPressed: (){

          Navigator.pop(context,_colors);
        },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            child: Text("SUBMIT",style: TextStyle(color: Colors.white),)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PickerCard(
              r: _r, g: _g, b: _b, a: _a,
              currentColor: _currentColor,
              labelController: _labelController,
              onChanged: (r, g, b, a) => setState(() {
                _r = r; _g = g; _b = b; _a = a;
              }),
              onAdd: _addColor, onAddEmptyBox: () {
              final label = _labelController.text.trim().isEmpty
                  ? 'color${_colors.length + 1}'
                  : _labelController.text.trim();

              setState(() {
                _colors.add(null);
                _labelController.clear();
              });
            },
            ),
            const SizedBox(height: 16),
            _ColorListCard(
              colors: _colors,
              onRemove: _removeColor,
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}

// ─── Picker Card ─────────────────────────────────────────────────────────────

class _PickerCard extends StatelessWidget {
  final int r, g, b, a;
  final Color currentColor;
  final TextEditingController labelController;
  final void Function(int r, int g, int b, int a) onChanged;
  final VoidCallback onAdd;
  final VoidCallback onAddEmptyBox;

  const _PickerCard({
    required this.r, required this.g, required this.b, required this.a,
    required this.currentColor,
    required this.labelController,
    required this.onChanged,
    required this.onAdd, required this.onAddEmptyBox,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
            ),
            const SizedBox(height: 16),

            // Preset swatches
            _PresetSwatches(
              onSelect: (c) => onChanged(c.red, c.green, c.blue, c.alpha),
            ),
            const SizedBox(height: 16),

            // RGBA sliders
            _SliderRow(label: 'R', value: r, color: Colors.red,
                onChanged: (v) => onChanged(v, g, b, a)),
            _SliderRow(label: 'G', value: g, color: Colors.green,
                onChanged: (v) => onChanged(r, v, b, a)),
            _SliderRow(label: 'B', value: b, color: Colors.blue,
                onChanged: (v) => onChanged(r, g, v, a)),
            _SliderRow(label: 'A', value: a, color: Colors.grey,
                onChanged: (v) => onChanged(r, g, b, v)),
            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add to list'),
            ),
            SizedBox(height: 10,),
            FilledButton.icon(
              onPressed: onAddEmptyBox,
              icon: const Icon(Icons.add),
              label: const Text('Add Empty'),
            ),


          ],
        ),
      ),
    );
  }
}

// ─── Slider Row ───────────────────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              inactiveTrackColor: color.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 255,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text('$value',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

// ─── Preset Swatches ─────────────────────────────────────────────────────────

class _PresetSwatches extends StatelessWidget {
  final ValueChanged<Color> onSelect;

  const _PresetSwatches({required this.onSelect});



  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((c) {
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Color List Card ──────────────────────────────────────────────────────────

class _ColorListCard extends StatelessWidget {
  final List<ColorEntry?> colors;
  final ValueChanged<int> onRemove;

  const _ColorListCard({required this.colors, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Color list',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${colors.length}'),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (colors.isEmpty)
              const Text('No colors yet. Add some above.',
                  style: TextStyle(color: Colors.grey))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: colors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final entry = colors[i];
                  return _ColorChip(
                    entry: entry,
                    onRemove: () => onRemove(i),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final ColorEntry? entry;
  final VoidCallback onRemove;

  const _ColorChip({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: entry?.color ?? Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry?.label??"Empty Box",
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(entry?.hexString ??"#FFFFFF",
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontFamily: 'monospace')),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
