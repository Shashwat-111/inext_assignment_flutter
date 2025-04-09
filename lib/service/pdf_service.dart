import 'package:pdf/widgets.dart' as pd;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generatePdf(List<String> questions) async {
    final pdf = pd.Document();

    pdf.addPage(
      pd.MultiPage(
        build: (context) => [
          pd.Column(
            crossAxisAlignment: pd.CrossAxisAlignment.start,
            children: questions
                .map((q) => pd.Padding(
              padding: const pd.EdgeInsets.only(bottom: 16),
              child: pd.Text(q, style: const pd.TextStyle(fontSize: 18)),
            )).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
