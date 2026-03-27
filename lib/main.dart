import 'package:votera/app/app.dart';
import 'package:votera/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}


