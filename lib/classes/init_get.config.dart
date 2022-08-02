// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:simple_logger/simple_logger.dart' as _i6;

import 'config_model.dart' as _i5;
import 'db_loader.dart' as _i3;
import 'log_wrapper.dart' as _i7;
import 'notify_model.dart' as _i4; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final logWrapper = _$LogWrapper();
  gh.singleton<_i3.DbLoader>(_i3.DbLoader());
  gh.factory<_i4.NotifyModel>(() => _i4.NotifyModel());
  gh.factory<_i5.ConfigModel>(() => _i5.ConfigModel(get<_i3.DbLoader>()));
  gh.factoryAsync<_i6.SimpleLogger>(
      () => logWrapper.getLog(get<_i5.ConfigModel>()));
  return get;
}

class _$LogWrapper extends _i7.LogWrapper {}
