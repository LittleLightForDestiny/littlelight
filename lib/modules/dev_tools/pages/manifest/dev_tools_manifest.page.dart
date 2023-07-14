import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/services/storage/export.dart';

class DevToolsManifest with StorageConsumer {
  DevToolsManifest._();
  static final instance = DevToolsManifest._();

  sqflite.Database? _db;

  Future<sqflite.Database?> _openDb() async {
    if (_db?.isOpen == true) {
      return _db;
    }

    final dbFile = await currentLanguageStorage.getManifestDatabaseFile();
    if (dbFile == null) return null;
    try {
      sqflite.Database database = await sqflite.openDatabase(dbFile.path, readOnly: true);
      _db = database;
    } catch (e) {
      logger.error(e);
      return null;
    }

    return _db;
  }

  Future<List<int>> getHashesByPatternSearch(String tableName, String pattern) async {
    sqflite.Database? db = await _openDb();
    List<int> hashes = [];
    if (db == null) return hashes;
    try {
      List<Map<String, dynamic>> results =
          await db.query(tableName, columns: ['id'], where: "json like ?", whereArgs: [pattern]);
      results.forEach((row) {
        final hash = row['id'].toInt();
        hashes.add(hash < 0 ? hash + (1 << 32) : hash);
      });
    } catch (e) {
      logger.error(e);
    }
    return hashes;
  }

  void itemScanTest(int testNumber) async {
    sqflite.Database? db = await _openDb();
    if (db == null) return;
    logger.info('Starting item scan test #${testNumber}');
    List<int> items = [];
    var cursor;
    int rows = 0;
    final startTime = DateTime.now();
    try {
      if (testNumber == 1) {
        cursor = await db.queryCursor('DestinyInventoryItemDefinition', columns: ['json'], bufferSize: 50);
      } else if (testNumber == 2) {
        cursor = await db.queryCursor('DestinyInventoryItemDefinition',
            columns: ['json'], where: 'json LIKE ?', whereArgs: ['%gCategoryId%fragments%']);
      } else {
        // Buffer size must hold all rows when using where clause even with
        // cursor. Bug?
        cursor = await db.queryCursor('DestinyInventoryItemDefinition',
            columns: ['json'],
            where: 'json LIKE ? or json LIKE ?',
            whereArgs: ['%gCategoryId%fragments%', '%gCategoryId%aspects%'],
            bufferSize: 500);
      }
      while (await cursor.moveNext()) {
        final Map<String, dynamic> row = cursor.current;
        rows++;
        final Map<String, dynamic> item = jsonDecode(row['json']);
        if (item.containsKey('plug')) {
          final Map<String, dynamic> plug = item['plug'];
          if (plug.containsKey('plugCategoryIdentifier')) {
            String label = plug['plugCategoryIdentifier'];
            if (label.endsWith('fragments') || label.endsWith('aspects')) {
              items.add(item['hash']);
            }
          }
        }
      }
    } catch (e) {
      logger.error(e);
    } finally {
      await cursor.close();
    }
    final requestTimeInMs = DateTime.now().difference(startTime).inMilliseconds;
    logger.info("Test #${testNumber} scanned ${rows} rows, found ${items.length} items in $requestTimeInMs ms");
  }
}

class DevToolsManifestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      appBar: AppBar(
        title: Text("Dev Tools Manifest"),
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
              onPressed: () async {
                DevToolsManifest.instance.itemScanTest(1);
              },
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Test 1:  Scan all rows"),
            ),
            ElevatedButton(
              onPressed: () async {
                DevToolsManifest.instance.itemScanTest(2);
              },
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Test 2: Query fragments"),
            ),
            ElevatedButton(
              onPressed: () async {
                DevToolsManifest.instance.itemScanTest(3);
              },
              style: ButtonStyle(visualDensity: VisualDensity.standard),
              child: Text("Test 3: Query fragments and aspects"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<int> hashes = await DevToolsManifest.instance
                    .getHashesByPatternSearch('DestinySocketTypeDefinition', '%masterworks.trackers%');
                logger.info("Got tracker hashes: ${hashes}");
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
