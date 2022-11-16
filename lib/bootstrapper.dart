import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/classes/calendar.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/debug_model.dart';
import 'package:work_tracker/classes/log_wrapper.dart';
import 'package:work_tracker/classes/notify_model.dart';
import 'package:work_tracker/classes/work_view_model.dart';

class Bootstrapper {
  // gh.singleton<_i3.DbLoader>(_i3.DbLoader());
  // gh.factory<_i4.NotifyModel>(() => _i4.NotifyModel());
  // gh.factory<_i5.WorkViewModel>(() => _i5.WorkViewModel());
  // gh.factory<_i6.ConfigModel>(() => _i6.ConfigModel(get<_i3.DbLoader>()));
  // gh.factory<_i7.DebugModel>(
  //     () => _i7.DebugModel(get<_i5.WorkViewModel>(), get<_i3.DbLoader>()));
  // gh.factoryAsync<_i8.SimpleLogger>(
  //     () => logWrapper.getLog(get<_i6.ConfigModel>()));

  static dynamic getProviders() {
    final notify = NotifyModel();
    final dbLoader = DbLoader();
    final workModel = WorkViewModel(dbLoader);
    return [
      RepositoryProvider(create: (_) => dbLoader),
      RepositoryProvider(create: (_) => workModel),
      RepositoryProvider(create: (_) => notify),
      RepositoryProvider(create: (_) => ConfigModel(dbLoader)),
      RepositoryProvider(create: (_) => Calendar()),
      RepositoryProvider(create: (_) => DebugModel(workModel, dbLoader)),
      RepositoryProvider(
          create: (_) => LogWrapper.getLog(ConfigModel(dbLoader))),
    ];
  }
}
