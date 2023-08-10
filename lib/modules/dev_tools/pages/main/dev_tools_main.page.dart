import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/dev_tools/pages/clarity/dev_tools_clarity.page_route.dart';
import 'package:little_light/modules/dev_tools/pages/plug_sources/dev_tools_plug_sources.page_route.dart';
import 'package:little_light/modules/dev_tools/pages/stats/dev_tools_stats.page_route.dart';
import 'package:little_light/modules/dev_tools/pages/manifest/dev_tools_manifest.page_route.dart';
import 'package:little_light/services/storage/export.dart';

class DevToolsPage extends StatelessWidget {
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
            SizedBox(height: 4),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(DevToolsManifestPageRoute()),
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Manifest"),
            ),
            SizedBox(height: 4),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(DevToolsPlugSourcesPageRoute()),
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Plug Sources"),
            ),
            SizedBox(height: 4),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(DevToolsClarityPageRoute()),
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Clarity"),
            ),
            SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                final globalStorage = getInjectedGlobalStorage();
                globalStorage.purge();
              },
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.standard,
                backgroundColor: context.theme.errorLayers.layer0,
              ),
              child: Text("Delete data"),
            ),
          ],
        ),
      ),
    );
  }
}
