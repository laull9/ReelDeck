import 'package:flutter/material.dart';

/// 下拉设置项。窄屏把选择框放到标题下方，避免长标题被挤成单字竖排。
class ChoiceTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const ChoiceTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  static const wideBreakpoint = 560.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= wideBreakpoint;
      final dropdown = DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        isExpanded: true,
      );
      if (wide) {
        return ListTile(
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.45),
            child: IntrinsicWidth(child: dropdown),
          ),
        );
      }
      return ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [if (subtitle != null) Text(subtitle!), dropdown],
        ),
      );
    },
  );
}
