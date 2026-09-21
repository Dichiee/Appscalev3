import 'dart:io';
import 'package:excel/excel.dart' as xls;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'excel_table_data.dart';

/// Builds a real .xlsx file on-device, entirely offline: constructs the
/// sheet in memory, encodes it to bytes, writes those bytes to a temp
/// file, then hands the file to the OS share sheet so the BNS can save
/// or send it. No server, no conversion service involved.
class ReportExcelService {
  Future<void> exportAndShare({required String fileTitle, required ExcelTableData data, required String metadataLine}) async {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['Report'];
    workbook.delete('Sheet1');

    sheet.appendRow([xls.TextCellValue(metadataLine)]);
    sheet.appendRow(data.headers.map((h) => xls.TextCellValue(h)).toList());
    for (final row in data.rows) {
      sheet.appendRow(row.map((v) => xls.TextCellValue(v)).toList());
    }

    final bytes = workbook.encode();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileTitle.xlsx');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: fileTitle);
  }
}