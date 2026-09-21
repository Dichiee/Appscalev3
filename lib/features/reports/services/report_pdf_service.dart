import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/report_signatory.dart';

/// Builds the consolidation report exactly as the paper form is laid
/// out — title, barangay/period header, an Old/New table, and the
/// four-signature block — as a real PDF, then opens the native
/// share/print/save sheet.
class ReportPdfService {
  Future<void> exportAndShare({
    required String fileTitle,
    required String title,
    required String barangay,
    required String period,
    required Map<String, int> newCounts,
    required Map<String, int>? oldCounts,
    required ReportSignatory? signatory,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text('CONSOLIDATION', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
            pw.Center(child: pw.Text(title, style: const pw.TextStyle(fontSize: 11))),
            pw.SizedBox(height: 6),
            pw.Text('Barangay: $barangay', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Period: $period', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 16),
            _buildTable(newCounts, oldCounts),
            pw.SizedBox(height: 28),
            if (signatory != null) _buildSignatureBlock(signatory),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: '$fileTitle.pdf');
  }

  pw.Widget _buildTable(Map<String, int> newCounts, Map<String, int>? oldCounts) {
    final headers = ['', 'Old', 'New'];
    final rows = newCounts.entries
        .map((e) => [e.key, (oldCounts?[e.key]?.toString() ?? '—'), e.value.toString()])
        .toList();
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(1), 2: const pw.FlexColumnWidth(1)},
    );
  }

  pw.Widget _buildSignatureBlock(ReportSignatory s) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sigLine(s.bnsName, 'Submitted by, BNS'),
        pw.SizedBox(height: 10),
        _sigLine(s.punongBarangayName, 'Noted by, Punong Barangay'),
        pw.SizedBox(height: 10),
        _sigLine(s.mnaoAdminAideName, 'Approved by, Admin Aide, MNAO'),
        pw.SizedBox(height: 10),
        _sigLine(s.dnpcName, 'Approved by, DNPC'),
      ],
    );
  }

  pw.Widget _sigLine(String name, String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Container(width: 200, decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 0.5))), padding: const pw.EdgeInsets.only(top: 2), child: pw.Text(label, style: const pw.TextStyle(fontSize: 8))),
      ],
    );
  }
}