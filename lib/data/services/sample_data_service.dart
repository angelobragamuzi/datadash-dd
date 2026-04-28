import 'package:uuid/uuid.dart';

import '../models/data_set_model.dart';
import 'data_processing_service.dart';

class SampleDataService {
  SampleDataService(this._processingService);

  final DataProcessingService _processingService;
  final Uuid _uuid = const Uuid();

  DataSetModel build() {
    final headers = ['Mes', 'Regiao', 'Receita', 'Pedidos', 'Conversao'];
    final rows = <List<dynamic>>[
      ['Jan', 'Norte', '12450', '312', '2.3'],
      ['Jan', 'Sul', '18420', '418', '2.7'],
      ['Fev', 'Norte', '15680', '355', '2.6'],
      ['Fev', 'Sul', '19210', '429', '2.9'],
      ['Mar', 'Norte', '17100', '380', '3.0'],
      ['Mar', 'Sul', '20590', '441', '3.1'],
      ['Abr', 'Norte', '18020', '401', '3.2'],
      ['Abr', 'Sul', '21440', '455', '3.4'],
    ];

    return _processingService.buildDataSet(
      id: _uuid.v4(),
      fileName: 'dataset_exemplo.csv',
      sourceType: 'sample',
      rawHeaders: headers,
      rawRows: rows,
    );
  }
}
