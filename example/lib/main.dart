import 'package:flutter/material.dart';
import 'package:auto_scroll_positioned_list/auto_scroll_positioned_list.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});
  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  final controller = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Auto Scroll Demo')),
        body: AutoScrollablePositionedList.builder(
          controller: controller,
          itemCount: 300,
          onTap: () => controller.toggle(), // tap toggles auto-scroll
          itemBuilder: (context, i) => ListTile(title: Text('Item $i')),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.toggle(),
                    child: const Text('Start / Stop'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: controller.decreaseSpeed,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: controller.increaseSpeed,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
