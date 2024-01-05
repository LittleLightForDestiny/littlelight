import 'package:flutter/material.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:provider/provider.dart';

class LogViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => logger,
      builder: (context, _) => _LogViewerPanel(
        context.watch<LoggerBloc>(),
      ),
    );
  }
}

class _LogViewerPanel extends StatelessWidget {
  final LoggerBloc state;
  _LogViewerPanel(this.state);
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
