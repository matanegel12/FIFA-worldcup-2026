import 'package:mvvm_remepy/view_model.dart';

import '../../../models/shame_entry.dart';

class ShamingTableModel extends Model {
  List<ShameEntry> entries = [];
  String? errorMessage;
  String? successMessage; // one-shot snackbar after a successful clear

  ShamingTableModel() {
    appBarTitle = 'Wall of Shame 🫣';
    isLoading = true;
  }
}
