import 'package:heroes/heroes.dart';

Future main() async {
  final app = Application<HeroesChannel>()
      ..options.configurationFilePath = "config.yaml"
      ..options.port = 8888;

  await app.start(numberOfInstances: Platform.numberOfProcessors ~/ 2);

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}