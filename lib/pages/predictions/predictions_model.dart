import 'package:mvvm_remepy/view_model.dart';

import '../../models/prediction_summary.dart';

class PredictionsModel extends Model {
  String? errorMessage;
  List<PredictionSummary> predictions = [];

  PredictionsModel() {
    appBarTitle = 'Your Predictions';
    isLoading = true;
  }
}
