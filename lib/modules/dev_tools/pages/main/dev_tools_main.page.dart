import 'package:flutter/material.dart';
import 'package:little_light/modules/dev_tools/pages/stats/dev_tools_stats.page_route.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

class DevToolsPage extends StatelessWidget with ManifestConsumer {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      appBar: AppBar(
        title: Text("Dev Tools"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: SingleChildScrollView(
        padding: MediaQuery.of(context).viewPadding.copyWith(top: 0) + EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(DevToolsStatsPageRoute()),
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Stats"),
            ),
            ElevatedButton(
              onPressed: () async {
                manifest.itemScanTest(1);
              },
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Test 1:  Scan all rows"),
            ),
            ElevatedButton(
              onPressed: () async {
                manifest.itemScanTest(2);
              },
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Test 2: Query fragments"),
            ),
            ElevatedButton(
              onPressed: () async {
                manifest.itemScanTest(3);
              },
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Test 3: Query fragments and aspects"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<int> hashes =
                    await manifest.getHashesByPatternSearch('DestinySocketTypeDefinition', '%masterworks.trackers%');
                print("Got tracker hashes: ${hashes}");
              },
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Find tracker socketType hashes"),
            ),
          ],
        ),
      ),
    );
  }
}
