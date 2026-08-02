import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    developer.log(
      'BLOC CHANGE: ${bloc.runtimeType}\n'
      '  CurrentState: ${change.currentState}\n'
      '  NextState: ${change.nextState}',
      name: 'AppBlocObserver',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    developer.log(
      'BLOC ERROR: ${bloc.runtimeType}\n  Error: $error',
      name: 'AppBlocObserver',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    developer.log(
      'BLOC EVENT: ${bloc.runtimeType}\n  Event: $event',
      name: 'AppBlocObserver',
    );
  }
}
