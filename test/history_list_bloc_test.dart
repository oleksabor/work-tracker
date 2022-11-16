import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/history_list/history_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'history_model_test.dart';

HistoryListBloc buildBloc() {
  var history = WorkViewModelDumbData().sut();
  var sut = HistoryListBloc(history, when: WorkViewModelDumbData.now);
  return sut;
}

void main() {
  group('HistoryLoadBloc', () {
    blocTest<HistoryListBloc, HistoryListState>("loading data on date",
        build: buildBloc,
        act: (bloc) =>
            bloc.add(HistoryLoadListEvent(when: WorkViewModelDumbData.now)),
        verify: (_) {
          expect(_.state.data.length, 2);
          expect(_.state.when, WorkViewModelDumbData.now);
        });
    blocTest<HistoryListBloc, HistoryListState>("loading data backward",
        build: buildBloc,
        act: (bloc) =>
            bloc.add(HistoryBackEvent(when: WorkViewModelDumbData.now)),
        verify: (_) {
          expect(_.state.data.length, 4);
          expect(_.state.when, WorkViewModelDumbData.beforeNow);
        });
    blocTest<HistoryListBloc, HistoryListState>("loading 2 data backward",
        build: buildBloc,
        act: (bloc) =>
            bloc.add(HistoryBackEvent(when: WorkViewModelDumbData.beforeNow)),
        verify: (_) {
          expect(_.state.data.length, 1);
          expect(_.state.when, WorkViewModelDumbData.kherson);
        });
    blocTest<HistoryListBloc, HistoryListState>("loading no data backward",
        build: buildBloc,
        act: (bloc) =>
            bloc.add(HistoryBackEvent(when: WorkViewModelDumbData.kherson)),
        verify: (_) {
          expect(_.state.data.isEmpty, true);
          expect(_.state.when, WorkViewModelDumbData.kherson);
        });
    blocTest<HistoryListBloc, HistoryListState>("loading data forward",
        build: buildBloc,
        act: (bloc) =>
            bloc.add(HistoryForwardEvent(when: WorkViewModelDumbData.kherson)),
        verify: (_) {
          expect(_.state.data.length, 4);
          expect(_.state.when, WorkViewModelDumbData.beforeNow);
        });
    blocTest<HistoryListBloc, HistoryListState>("loading data forward 2",
        build: buildBloc,
        act: (bloc) => bloc
            .add(HistoryForwardEvent(when: WorkViewModelDumbData.beforeNow)),
        verify: (_) {
          expect(_.state.data.length, 2);
          expect(_.state.when, WorkViewModelDumbData.now);
        });
    blocTest<HistoryListBloc, HistoryListState>("loading no data forward",
        build: buildBloc,
        act: (bloc) =>
            bloc.add(HistoryForwardEvent(when: WorkViewModelDumbData.now)),
        verify: (_) {
          expect(_.state.data.isEmpty, true);
          expect(_.state.when, WorkViewModelDumbData.now);
        });
  });
}
