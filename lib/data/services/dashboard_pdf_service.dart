import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/formatters.dart';
import '../models/dashboard_model.dart';
import '../models/dashboard_widget_model.dart';
import '../models/data_set_model.dart';
import 'data_processing_service.dart';

class DashboardPdfService {
  DashboardPdfService(this._processingService);

  final DataProcessingService _processingService;

  Future<Uint8List> buildPdf({
    required DashboardModel dashboard,
    required DataSetModel dataSet,
  }) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) {
          final widgets = <pw.Widget>[
            pw.Text(
              dashboard.name,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Exportado em ${Formatters.dateTime(DateTime.now())}'),
            pw.SizedBox(height: 18),
          ];

          for (final widget in dashboard.widgets) {
            widgets
              ..add(_widgetSection(widget, dataSet))
              ..add(pw.SizedBox(height: 16));
          }

          if (dashboard.widgets.isEmpty) {
            widgets.add(pw.Text('Dashboard sem widgets.'));
          }

          return widgets;
        },
      ),
    );

    return document.save();
  }

  Future<File> savePdf(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${directory.path}/$safeName.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  pw.Widget _widgetSection(DashboardWidgetModel widget, DataSetModel dataSet) {
    final title = pw.Text(
      widget.title,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
    );

    switch (widget.type) {
      case DashboardWidgetType.indicator:
        final value = _processingService.aggregate(
          dataSet,
          columnKey: widget.columnKey,
          aggregation: widget.aggregation,
          filter: widget.filter,
        );
        return pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              title,
              pw.SizedBox(height: 8),
              pw.Text(
                Formatters.number(value),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case DashboardWidgetType.barChart:
      case DashboardWidgetType.lineChart:
      case DashboardWidgetType.pieChart:
        final points = _processingService.groupedAggregation(
          dataSet: dataSet,
          valueColumnKey: widget.columnKey,
          aggregation: widget.aggregation,
          filter: widget.filter,
        );
        final max = points.isEmpty
            ? 1.0
            : points
                  .map((point) => point.value)
                  .reduce((a, b) => a > b ? a : b);

        return pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              title,
              pw.SizedBox(height: 10),
              ...points.map((point) {
                final ratio = (point.value / max).clamp(0, 1).toDouble();
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 90,
                        child: pw.Text(point.label, maxLines: 1),
                      ),
                      pw.SizedBox(
                        width: 140,
                        child: pw.Stack(
                          children: [
                            pw.Container(
                              height: 10,
                              decoration: pw.BoxDecoration(
                                color: PdfColors.blue100,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                            ),
                            pw.Container(
                              width: 140 * ratio,
                              height: 10,
                              decoration: pw.BoxDecoration(
                                color: PdfColors.indigo700,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(Formatters.number(point.value)),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      case DashboardWidgetType.summaryTable:
        final rows = _processingService.summaryRows(dataSet, maxRows: 8);
        final columns = dataSet.visibleColumns;
        return pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              title,
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: columns.map((column) => column.label).toList(),
                data: rows
                    .map(
                      (row) => columns
                          .map((column) => row[column.key]?.toString() ?? '')
                          .toList(),
                    )
                    .toList(),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        );
    }
  }
}
