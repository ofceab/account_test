import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:localauth/models/user_transaction.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class PdfCreator {
  static Future createOneUserRapport(User user) async {
    print(user.transactionList.length);
    final pdf =
        pw.Document(author: 'Account Manager', creator: 'Account Manager');

    //add Page
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
                level: 0,
                child:
                    pw.Text('${user.name}', style: pw.TextStyle(fontSize: 35))),
            pw.Header(
                level: 2,
                child: pw.Table(children: [
                  pw.TableRow(children: [
                    pw.Container(
                      alignment: pw.Alignment.center,
                      width: 300,
                      child: pw.Text('Transaction Date',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(Colors.black.value))),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      width: 300,
                      child: pw.Text('Particular',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(Colors.orange.value))),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      width: 300,
                      child: pw.Text('Credit',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(Colors.green.value))),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      width: 300,
                      child: pw.Text('Debit',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(Colors.red.value))),
                    ),
                  ])
                ])),
            pw.Table(
                children: user.transactionList.map((dynamic transaction) {
              return pw.TableRow(children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  width: 300,
                  child: pw.Text(transaction.transactionDate,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(Colors.black.value))),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  width: 300,
                  child: pw.Text(transaction.particular,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(Colors.black.value))),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  width: 300,
                  child: pw.Text('${transaction.credit.toString()}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(Colors.black.value))),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  width: 300,
                  child: pw.Text('${transaction.debit.toString()}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(Colors.black.value))),
                )
              ]);
            }).toList()),
            pw.Footer(
                title: pw.Header(
                    margin: pw.EdgeInsets.only(top: 15),
                    level: 2,
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.RichText(
                            textAlign: pw.TextAlign.left,
                            text: pw.TextSpan(
                                text: 'Credit Total Amount: ',
                                children: [
                                  pw.TextSpan(
                                      style: pw.TextStyle(
                                        color: PdfColor.fromInt(
                                            Colors.green.value),
                                      ),
                                      text:
                                          '${_calculateCreditTotal(user)['credit']}')
                                ]),
                          ),
                          pw.RichText(
                            textAlign: pw.TextAlign.left,
                            text: pw.TextSpan(
                                text: 'Debit Total Amount:  ',
                                children: [
                                  pw.TextSpan(
                                      style: pw.TextStyle(
                                        color: PdfColor.fromInt(
                                            Colors.orange.value),
                                      ),
                                      text:
                                          '${_calculateCreditTotal(user)['debit']}')
                                ]),
                          ),
                          pw.RichText(
                            textAlign: pw.TextAlign.left,
                            text: pw.TextSpan(
                                text: 'Balance Total Amount:  ',
                                children: [
                                  pw.TextSpan(
                                      style: pw.TextStyle(
                                        color:
                                            PdfColor.fromInt(Colors.red.value),
                                      ),
                                      text:
                                          '${_calculateCreditTotal(user)['balance']}')
                                ]),
                          ),
                        ])))
          ];
        }));
    // final String directory =
    // final String path = '$directory/account-${user.name}.pdf';
    // final File file = File(path);
    // file.writeAsBytes(pdf.save());
    // //Open the PDF document in mobile
    // OpenFile.open(path);
  }

  static Future createAllUsersRapports(List<User> users) async {
    final pdf =
        pw.Document(author: 'Account Manager', creator: 'Account Manager');

    //add Page
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        header: (pw.Context context) {
          return pw.Header(
              level: 0,
              child: pw.Text('Account Manager',
                  style: pw.TextStyle(fontSize: 35)));
        },
        build: (pw.Context context) {
          return _buildFullList(users);
        }));

    if ((await Permission.storage.request()).isGranted) {
      final Directory _rootDir = await DownloadsPathProvider.downloadsDirectory;
      print(_rootDir.parent.parent.parent.parent.path);
      final Directory _specificFolder = Directory('${_rootDir.path}/reports');
      String directory;
      if (await _specificFolder.exists()) {
        directory = _specificFolder.path;
      } else {
        _specificFolder.create(recursive: true);
        directory = _specificFolder.path;
      }
      print(directory);
      print('"dgf');
      final String path =
          '$directory/account_full_report(${DateTime.now().month}_${DateTime.now().day}_${DateTime.now().year}(${DateTime.now().hour}:${DateTime.now().minute})).pdf';
      final File file = File(path);
      file.writeAsBytes(pdf.save());
      //Open the PDF document in mobile
      OpenFile.open(path);
    }
  }

  ///For calculation purpose
  static Map<String, double> _calculateCreditTotal(User user) {
    double _creditTotalAmount = 0;
    double _balanceTotalAmount = 0;
    double _debitTotalAmount = 0;
    user.transactionList.forEach((dynamic transaction) {
      _creditTotalAmount += transaction.credit;
      _debitTotalAmount += transaction.debit;
      _balanceTotalAmount += (transaction.credit - transaction.debit);
    });

    return {
      'credit': _creditTotalAmount,
      'debit': _debitTotalAmount,
      'balance': _balanceTotalAmount,
    };
  }

  //Build Full List Widget
  static List<pw.Widget> _buildFullList(List<User> users) {
    return users.map((User user) {
      return pw.Column(children: [
        pw.Header(level: 2, child: pw.Text(user.name)),
        pw.Header(
            level: 2,
            child: pw.Table(children: [
              pw.TableRow(children: [
                pw.Text('Transaction Date',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(Colors.black.value))),
                pw.Text('Particular',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(Colors.orange.value))),
                pw.Text('Credit',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(Colors.green.value))),
                pw.Text('Debit',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(Colors.red.value))),
              ])
            ])),
        pw.Table(
            tableWidth: pw.TableWidth.max,
            children: user.transactionList.map((dynamic transaction) {
              return pw.TableRow(children: [
                pw.Text(
                  transaction.transactionDate,
                  textAlign: pw.TextAlign.right,
                ),
                pw.Text(
                  transaction.particular,
                  textAlign: pw.TextAlign.right,
                ),
                pw.Text(
                  '${transaction.credit.toString()}',
                  textAlign: pw.TextAlign.right,
                ),
                pw.Text(
                  '${transaction.debit.toString()}',
                  textAlign: pw.TextAlign.right,
                ),
              ]);
            }).toList()),
        pw.Header(
            margin: pw.EdgeInsets.only(top: 15, bottom: 25),
            level: 2,
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    textAlign: pw.TextAlign.left,
                    text: pw.TextSpan(text: 'Credit Total Amount: ', children: [
                      pw.TextSpan(
                          style: pw.TextStyle(
                            color: PdfColor.fromInt(Colors.green.value),
                          ),
                          text: '${_calculateCreditTotal(user)['credit']}')
                    ]),
                  ),
                  pw.RichText(
                    textAlign: pw.TextAlign.left,
                    text: pw.TextSpan(text: 'Debit Total Amount:  ', children: [
                      pw.TextSpan(
                          style: pw.TextStyle(
                            color: PdfColor.fromInt(Colors.green.value),
                          ),
                          text: '${_calculateCreditTotal(user)['debit']}')
                    ]),
                  ),
                  pw.RichText(
                    textAlign: pw.TextAlign.left,
                    text:
                        pw.TextSpan(text: 'Balance Total Amount:  ', children: [
                      pw.TextSpan(
                          style: pw.TextStyle(
                            color: PdfColor.fromInt(Colors.green.value),
                          ),
                          text: '${_calculateCreditTotal(user)['balance']}')
                    ]),
                  ),
                ]))
      ]);
    }).toList();
  }
}
