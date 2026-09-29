import 'dart:io';
import 'package:flutter/foundation.dart'
    show
        kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart'
    as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:mockmaster/features/interview/services/feedback_service.dart';

/// Builds a PDF summary of a finished interview (score, strengths,
/// improvements, and the full Q&A transcript).
///
/// On Android/iOS: saves the file to device storage using dart:io and
/// returns the real file path.
/// On Web: dart:io/Platform.* don't exist in a browser sandbox (calling
/// them throws "Unsupported operation"), so this branches to `printing`'s
/// [Printing.sharePdf], which triggers a normal browser file download
/// instead. No `kIsWeb` branch touches Platform/File/Directory at all,
/// which is what avoids the crash.
class FeedbackPdfService {
  static Future<
    String
  >
  generateAndSave({
    required String
    interviewTitle,
    required List<
      String
    >
    questions,
    required Map<
      int,
      String
    >
    answers,
    required InterviewEvaluation
    evaluation,
  }) async {
    final doc = _buildDocument(
      interviewTitle: interviewTitle,
      questions: questions,
      answers: answers,
      evaluation: evaluation,
    );

    final bytes =
        await doc.save();
    final fileName =
        'interview_feedback_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // -- Web: trigger a browser download, no filesystem access needed. --
    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName,
      );
      return fileName; // no real path on web -- just used for the UI message
    }

    // -- Android/iOS: write to real device storage. ----------------------
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isPermanentlyDenied) {
        throw Exception(
          'Storage permission denied. Enable it in device Settings to save the PDF.',
        );
      }
    }

    final targetDir =
        await _resolveTargetDirectory();
    final file = File(
      '$targetDir/$fileName',
    );
    await file.writeAsBytes(
      bytes,
    );
    return file.path;
  }

  static Future<
    String
  >
  _resolveTargetDirectory() async {
    if (Platform.isAndroid) {
      try {
        final downloadsDir = Directory(
          '/storage/emulated/0/Download',
        );
        if (await downloadsDir.exists()) {
          return downloadsDir.path;
        }
      } catch (
        _
      ) {
        // fall through to app-specific storage below
      }
      final fallback = await getExternalStorageDirectory();
      if (fallback !=
          null)
        return fallback.path;
      throw Exception(
        'Could not access any storage directory on this device.',
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }

  static pw.Document
  _buildDocument({
    required String
    interviewTitle,
    required List<
      String
    >
    questions,
    required Map<
      int,
      String
    >
    answers,
    required InterviewEvaluation
    evaluation,
  }) {
    final doc =
        pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (
              context,
            ) => [
              pw.Text(
                interviewTitle,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(
                'Generated on ${DateTime.now().toString().split('.').first}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(
                height: 20,
              ),

              // -- Score ---------------------------------------------------
              pw.Container(
                padding: const pw.EdgeInsets.all(
                  16,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(
                    8,
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Overall Score',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${evaluation.overallScore}%',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(
                height: 20,
              ),

              // -- Strengths -------------------------------------------------
              pw.Text(
                'Strengths',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                height: 6,
              ),
              ...evaluation.strengths.map(
                (
                  s,
                ) => pw.Padding(
                  padding: const pw.EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: pw.Text(
                    '• $s',
                    style: const pw.TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(
                height: 16,
              ),

              // -- Improvements ------------------------------------------------
              pw.Text(
                'Areas to Improve',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                height: 6,
              ),
              ...evaluation.improvements.map(
                (
                  s,
                ) => pw.Padding(
                  padding: const pw.EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: pw.Text(
                    '• $s',
                    style: const pw.TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(
                height: 20,
              ),

              // -- Q&A transcript ------------------------------------------
              pw.Text(
                'Question-by-Question',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                height: 8,
              ),
              ...List.generate(
                questions.length,
                (
                  i,
                ) {
                  final answer =
                      answers[i]?.trim() ??
                      '';
                  final qEval =
                      evaluation.perQuestion.length >
                          i
                      ? evaluation.perQuestion[i]
                      : null;

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(
                      bottom: 10,
                    ),
                    padding: const pw.EdgeInsets.all(
                      10,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.grey300,
                      ),
                      borderRadius: pw.BorderRadius.circular(
                        6,
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Q${i + 1}. ${questions[i]}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            if (qEval !=
                                null)
                              pw.Text(
                                '${qEval.score}%',
                                style: const pw.TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        pw.SizedBox(
                          height: 4,
                        ),
                        pw.Text(
                          answer.isEmpty
                              ? 'No answer recorded (skipped)'
                              : answer,
                          style: const pw.TextStyle(
                            fontSize: 11,
                          ),
                        ),
                        if (qEval !=
                                null &&
                            qEval.feedback.isNotEmpty) ...[
                          pw.SizedBox(
                            height: 4,
                          ),
                          pw.Text(
                            qEval.feedback,
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
      ),
    );

    return doc;
  }
}
