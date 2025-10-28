import 'package:flutter/material.dart';

class QueueStateService 
{
  // Singleton pattern to ensure the same instance is used everywhere
  static final QueueStateService _instance = QueueStateService._internal();
  
  factory QueueStateService() {return _instance;}
  
  QueueStateService._internal();

  // ValueNotifiers allow widgets to listen to changes without rebuilding entire trees
  final ValueNotifier<bool> isQueueActive = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isFullScreen = ValueNotifier<bool>(false);

  void setQueueActive(bool value) {isQueueActive.value = value;}

  void setFullScreen(bool value) {isFullScreen.value = value;}
}