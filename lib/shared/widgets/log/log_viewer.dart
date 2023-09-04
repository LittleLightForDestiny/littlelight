import 'package:flutter/material.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

extension on Level {
  Color get color {
    switch (this) {
      case Level.verbose:
        return Colors.white;
      case Level.debug:
        return Colors.amber;
      case Level.info:
        return Colors.blue;
      case Level.warning:
        return Colors.orange;
      case Level.error:
        return Colors.red;
      case Level.wtf:
        return Colors.purple;
      case Level.nothing:
        return Colors.white;
    }
  }
}

class LogViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => logger,
      builder: (context, child) => _LogViewerWidget(context.watch<LoggerBloc>()),
    );
  }
}

class _LogViewerWidget extends StatelessWidget {
  final LoggerBloc state;
  const _LogViewerWidget(this.state);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SingleChildScrollView(
        reverse: true,
        child: Material(
          color: Colors.black38,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: state.messages.map((e) => buildEntry(context, e)).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildEntry(BuildContext context, LogEntry entry) {
    return DefaultTextStyle(
        style: TextStyle(color: entry.level.color),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
              children: [
            buildMessage(context, entry),
            buildError(context, entry),
            buildStackTrace(context, entry),
          ].whereType<Widget>().toList()),
        ));
  }

  Widget? buildMessage(BuildContext context, LogEntry entry) {
    if (entry.message == null) return null;
    final message = entry.message.toString();
    return Container(
      child: Text(message),
    );
  }

  Widget? buildError(BuildContext context, LogEntry entry) {
    if (entry.error == null) return null;
    final message = entry.error.toString();
    return Container(
      child: Text(message),
    );
  }

  Widget? buildStackTrace(BuildContext context, LogEntry entry) {
    if (entry.stackTrace == null) return null;
    final message = entry.stackTrace.toString();
    return Container(
      child: Text(message),
    );
  }
}
