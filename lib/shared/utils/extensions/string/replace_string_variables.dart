import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/shared/utils/extensions/number/to_decimal.dart';
import 'package:provider/provider.dart';

String replaceStringVariables(BuildContext context, ProfileBloc profile, String input) {
  String resultText = input;
  final varFinder = RegExp(r"\{var:(\d*)\}");
  final hasVars = varFinder.hasMatch(resultText);
  if (!hasVars) return resultText;

  resultText = resultText.replaceAllMapped(varFinder, (match) {
    final hash = match.group(1);
    final replacement = profile.stringVariable(hash);
    final replacementStr = replacement?.toDecimal(context);
    return replacementStr ?? match.group(0) ?? "";
  });

  return resultText;
}

extension ReplaceStringVariables on String {
  String replaceBungieVariables(BuildContext context, {bool useReadContext = false}) {
    final profile = useReadContext ? context.read<ProfileBloc>() : context.watch<ProfileBloc>();
    return replaceStringVariables(context, profile, this);
  }
}
