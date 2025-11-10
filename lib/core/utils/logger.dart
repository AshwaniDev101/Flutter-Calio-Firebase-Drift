import 'package:logger/logger.dart';


final log = Logger(
  // Set to Level.debug to see everything: verbose, debug, info, warning, error.
  level: Level.debug,

  // PrettyPrinter formats the output nicely with colors and symbols.
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,

  ),
);