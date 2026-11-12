import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('tr_TR'),
    initializeDateFormatting('en_US'),
  ]);
  runApp(const GoldPortfolioApp());
}
