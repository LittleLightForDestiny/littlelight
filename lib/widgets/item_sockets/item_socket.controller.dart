import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_plug_set_definition.dart';
import 'package:flutter/widgets.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

class ItemSocketController extends ChangeNotifier {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  List<DestinyItemSocketState> _socketStates;
  List<int> _selectedSockets;
  List<int> _randomizedSelectedSockets;
  Map<int, DestinyInventoryItemDefinition> _plugDefinitions;
  Map<int, DestinyPlugSetDefinition> _plugSetDefinitions;
  Map<int, DestinyInventoryItemDefinition> get plugDefinitions =>
      _plugDefinitions;
  int _selectedSocket;
  int _selectedSocketIndex;

  List<int> get selectedSockets => _selectedSockets;
  List<int> get randomizedSelectedSockets => _randomizedSelectedSockets;

  ItemSocketController({this.item, this.definition}) {
    _initDefaults();
    _loadPlugDefinitions();
  }

  _initDefaults() {
    var entries = definition?.sockets?.socketEntries;
    _socketStates = ProfileService().getItemSockets(item?.itemInstanceId);
    _selectedSockets = List<int>(entries?.length ?? 0);
    _randomizedSelectedSockets = List<int>(entries?.length ?? 0);
  }

  Future<void> _loadPlugDefinitions() async {
    Set<int> plugHashes = new Set();
    var manifest = ManifestService();
    if (_socketStates != null) {
      plugHashes = _socketStates
          .expand((socket) {
            Set<int> hashes = new Set();
            hashes.add(socket.plugHash);
            hashes.addAll(socket.reusablePlugHashes ?? []);
            return hashes;
          })
          .where((i) => (i ?? 0) != 0)
          .toSet();
    } else {
      Set<int> plugSetHashes = definition.sockets.socketEntries
          .expand((s) => [s.reusablePlugSetHash, s.randomizedPlugSetHash])
          .where((h) => ((h ?? 0) != 0))
          .toSet();
      _plugSetDefinitions = await manifest
          .getDefinitions<DestinyPlugSetDefinition>(plugSetHashes);

      plugHashes = definition.sockets.socketEntries
          .expand((socket) {
            List<int> hashes = [];
            hashes.add(socket.singleInitialItemHash);
            hashes.addAll(
                socket.reusablePlugItems?.map((p) => p.plugItemHash) ?? []);
            DestinyPlugSetDefinition reusablePlugSet =
                _plugSetDefinitions[socket.reusablePlugSetHash];
            DestinyPlugSetDefinition randomizedPlugSet =
                _plugSetDefinitions[socket.randomizedPlugSetHash];
            hashes.addAll(reusablePlugSet?.reusablePlugItems
                    ?.map((i) => i?.plugItemHash) ??
                []);
            hashes.addAll(randomizedPlugSet?.reusablePlugItems
                    ?.map((i) => i?.plugItemHash) ??
                []);
            return hashes;
          })
          .where((i) => (i ?? 0) != 0)
          .toSet();
    }
    _plugDefinitions = await manifest
        .getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    notifyListeners();
  }

  int get selectedSocketIndex => _selectedSocketIndex;
  int get selectedPlugHash => _selectedSocket;

  selectSocket(int socketIndex, int plugHash) {
    if (plugHash == this._selectedSocket && socketIndex == _selectedSocketIndex) {
      this._selectedSocketIndex = null;
      this._selectedSocket = null;
      this._selectedSockets[socketIndex] = null;
    } else {
      this._selectedSocketIndex = socketIndex;
      this._selectedSocket = plugHash;
      this._selectedSockets[socketIndex] = plugHash;
      var plugHashes = socketPlugHashes(socketIndex);
      if(!plugHashes.contains(plugHash)){
        this._randomizedSelectedSockets[socketIndex] = plugHash;
      }
    }
    this.notifyListeners();
  }

  Set<int> socketPlugHashes(int socketIndex) {
    if (_socketStates != null) {
      var state = _socketStates?.elementAt(socketIndex);
      if (state.isVisible == false) return null;
      if (state.plugHash == null) return null;
      if ((state?.reusablePlugHashes?.length ?? 0) > 0) {
        return state?.reusablePlugHashes?.toSet();
      }
      return [state?.plugHash].where((s) => s != null).toSet();
    }
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);

    if ((entry?.reusablePlugItems?.length ?? 0) > 0) {
      return entry?.reusablePlugItems
          ?.map((p) => p.plugItemHash)
          ?.where((h) => h != 0 && h != null)
          ?.toSet();
    }

    if ((entry?.singleInitialItemHash ?? 0) != 0) {
      return [entry?.singleInitialItemHash].toSet();
    }
    return Set();
  }

  List<int> randomizedPlugHashes(int socketIndex) {
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    if ((entry?.randomizedPlugSetHash ?? 0) == 0) return [];
    if (_plugSetDefinitions == null) return [];
    return _plugSetDefinitions[entry?.randomizedPlugSetHash]
        .reusablePlugItems
        .map((p) => p.plugItemHash)
        .toList();
  }

  List<int> bungieRollPlugHashes(int socketIndex) {
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);

    if ((entry?.reusablePlugItems?.length ?? 0) > 0) {
      return entry?.reusablePlugItems?.map((p) => p.plugItemHash)?.toList();
    }
    if ((entry?.singleInitialItemHash ?? 0) != 0) {
      return [entry.singleInitialItemHash];
    }
    return [];
  }

  int socketEquippedPlugHash(int socketIndex) {
    if (_socketStates != null) {
      var state = _socketStates?.elementAt(socketIndex);
      return state.plugHash ?? state?.reusablePlugHashes?.elementAt(0);
    }
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    if ((entry?.singleInitialItemHash ?? 0) != 0) {
      return entry?.singleInitialItemHash;
    }
    var socketPlugs = socketPlugHashes(socketIndex);
    if ((socketPlugs?.length ?? 0) > 0) {
      return socketPlugs.first;
    }
    var random = randomizedPlugHashes(socketIndex);
    if ((random?.length ?? 0) > 0) {
      return random.first;
    }
    return null;
  }

  int socketSelectedPlugHash(int socketIndex) {
    var selected = selectedSockets?.elementAt(socketIndex);
    if (selected != null) return selected;
    if (_socketStates != null) {
      var state = _socketStates?.elementAt(socketIndex);
      return state.plugHash ?? state?.reusablePlugHashes?.elementAt(0);
    }
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    return entry?.singleInitialItemHash ??
        entry.reusablePlugItems?.elementAt(0)?.plugItemHash;
  }

  int socketRandomizedSelectedPlugHash(int socketIndex) {
    var selected = randomizedSelectedSockets?.elementAt(socketIndex);
    if (selected != null) return selected;
    return 2328497849;
  }
}
