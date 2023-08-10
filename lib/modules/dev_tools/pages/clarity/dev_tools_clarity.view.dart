import 'package:flutter/material.dart';
import 'package:little_light/modules/dev_tools/pages/clarity/dev_tools_clarity.bloc.dart';
import 'package:provider/provider.dart';

class DevToolsClarityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<DevToolsClarityBloc>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Dev Tools Clarity"),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: state.items?.length,
            itemBuilder: (context, index) {
              final item = state.items?[index];
              if (item == null) return null;
              return null;
            },
          ),
          Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: ElevatedButton(
                child: Text("Reload"),
                onPressed: () => context.read<DevToolsClarityBloc>().load(),
              )),
        ],
      ),
    );
  }
}
