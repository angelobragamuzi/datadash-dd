import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/data_set_model.dart';

class ImportRepository {
  ImportRepository(this._box);

  final Box<String> _box;

  List<DataSetModel> getAll() {
    final result = _box.values
        .map(
          (value) =>
              DataSetModel.fromJson(jsonDecode(value) as Map<String, dynamic>),
        )
        .toList();

    result.sort((a, b) => b.importedAt.compareTo(a.importedAt));
    return result;
  }

  DataSetModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return DataSetModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(DataSetModel dataSet) {
    return _box.put(dataSet.id, jsonEncode(dataSet.toJson()));
  }

  Future<void> delete(String id) {
    return _box.delete(id);
  }
}
