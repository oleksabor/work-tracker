import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/history_list/history_list_bloc.dart';
import 'package:work_tracker/classes/history_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'dart:convert';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:work_tracker/classes/work_view_model.dart';

import 'history_model_test.dart';

HistoryListBloc buildBloc() {
  var history = WorkViewModelDumbData().sut();
  var sut = HistoryListBloc(history, when: WorkViewModelDumbData.now);
  return sut;
}

void main() {
  test('history bloc items on date', () async {
    blocTest<HistoryListBloc, HistoryListState>("loading data on date",
        build: buildBloc,
        act: (bloc) =>
            bloc.add(HistoryLoadListEvent(when: WorkViewModelDumbData.now)),
        verify: (_) {
          expect(_.state.data.length, 2);
        });
  });
}
