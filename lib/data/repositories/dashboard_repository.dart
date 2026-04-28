import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/dashboard_model.dart';

class DashboardRepository {
  DashboardRepository(this._box);

  final Box<String> _box;

  List<DashboardModel> getAll() {
    final result = _box.values
        .map(
          (value) => DashboardModel.fromJson(
            jsonDecode(value) as Map<String, dynamic>,
          ),
        )
        .toList();

    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  DashboardModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return DashboardModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<DashboardModel> getByDataSetId(String dataSetId) {
    return getAll()
        .where((dashboard) => dashboard.dataSetId == dataSetId)
        .toList();
  }

  Future<void> save(DashboardModel dashboard) {
    return _box.put(dashboard.id, jsonEncode(dashboard.toJson()));
  }

  Future<void> delete(String id) {
    return _box.delete(id);
  }
}
