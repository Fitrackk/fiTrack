import 'package:bloc/bloc.dart';

enum BottomNavEvent { home, chart, challenge, settings }

class BottomNavBloc extends Bloc<BottomNavEvent, int> {
  BottomNavBloc() : super(0) {
    on<BottomNavEvent>((event, emit) {
      switch (event) {
        case BottomNavEvent.home:
          emit(0);
          break;
        case BottomNavEvent.chart:
          emit(1);
          break;
        case BottomNavEvent.challenge:
          emit(2);
          break;
        case BottomNavEvent.settings:
          emit(3);
          break;
      }
    });
  }
}
