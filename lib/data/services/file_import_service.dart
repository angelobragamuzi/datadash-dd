import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/app_exception.dart';
import '../models/data_set_model.dart';
import 'data_processing_service.dart';

class FileImportService {
  FileImportService(this._processingService);

  final DataProcessingService _processingService;
  final Uuid _uuid = const Uuid();

  Future<DataSetModel> pickAndParseFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xls', 'xlsx'],
    );

    if (result == null || result.files.isEmpty) {
      throw const AppException('Nenhum arquivo selecionado.');
    }

    return parsePlatformFile(result.files.first);
  }

  Future<DataSetModel> parsePlatformFile(PlatformFile file) async {
    final bytes = await _resolveBytes(file);
    final extension = (file.extension ?? _extensionFromName(file.name))
        .toLowerCase();

    switch (extension) {
      case 'csv':
        return _parseCsv(file, bytes);
      case 'xlsx':
      case 'xls':
        return _parseExcel(file, bytes, extension);
      default:
        throw const AppException('Formato inválido. Use CSV, XLS ou XLSX.');
    }
  }

  Future<Uint8List> _resolveBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes!;
    }
    if (file.path != null) {
      return File(file.path!).readAsBytes();
    }
    throw const AppException('Não foi possível ler o arquivo selecionado.');
  }

  DataSetModel _parseCsv(PlatformFile file, Uint8List bytes) {
    final content = utf8.decode(bytes, allowMalformed: true);
    final delimiter = _guessDelimiter(content);

    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(content, fieldDelimiter: delimiter);

    if (rows.isEmpty) {
      throw const AppException('CSV vazio ou inválido.');
    }

    final headers = rows.first.map((cell) => cell.toString()).toList();
    final dataRows = rows.skip(1).map((row) => row.toList()).toList();

    return _processingService.buildDataSet(
      id: _uuid.v4(),
      fileName: file.name,
      sourceType: 'csv',
      sourcePath: file.path,
      rawHeaders: headers,
      rawRows: dataRows,
    );
  }

  DataSetModel _parseExcel(
    PlatformFile file,
    Uint8List bytes,
    String extension,
  ) {
    try {
      final workbook = Excel.decodeBytes(bytes);
      if (workbook.tables.isEmpty) {
        throw const AppException('Planilha sem abas válidas.');
      }

      final firstSheet = workbook.tables.values.firstWhere(
        (sheet) => sheet.maxRows > 0,
        orElse: () => workbook.tables.values.first,
      );

      final rows = firstSheet.rows;
      if (rows.isEmpty) {
        throw const AppException('Planilha vazia.');
      }

      final headers = rows.first
          .map((cell) => _cellToString(cell?.value).trim())
          .toList();

      final dataRows = rows.skip(1).map((row) {
        return row.map((cell) => _cellToDynamic(cell?.value)).toList();
      }).toList();

      return _processingService.buildDataSet(
        id: _uuid.v4(),
        fileName: file.name,
        sourceType: extension,
        sourcePath: file.path,
        rawHeaders: headers,
        rawRows: dataRows,
      );
    } catch (error) {
      throw AppException('Erro ao ler planilha $extension: $error');
    }
  }

  String _cellToString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }

  dynamic _cellToDynamic(Object? value) {
    if (value == null) return null;
    return value.toString();
  }

  String _guessDelimiter(String content) {
    final firstLine = content.split('\n').firstOrNull ?? '';
    final comma = ','.allMatches(firstLine).length;
    final semicolon = ';'.allMatches(firstLine).length;
    return semicolon > comma ? ';' : ',';
  }

  String _extensionFromName(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index == -1) return '';
    return fileName.substring(index + 1);
  }
}

extension on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
