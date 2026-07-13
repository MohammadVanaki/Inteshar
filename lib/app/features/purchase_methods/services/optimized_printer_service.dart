import 'dart:async';
import 'dart:ui' as ui;
import 'package:barcode/barcode.dart' as bc;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:screenshot/screenshot.dart';

class OptimizedPrinterService {
  static CapabilityProfile? _profile;
  static Generator? _generator;

  // Memory caches for downloaded and decoded images to avoid repeating network and CPU load
  static ui.Image? _logoImageCache;
  static final Map<String, ui.Image?> _cardImageCache = {};

  static Future<Generator> _getGenerator() async {
    if (_generator != null) return _generator!;
    _profile ??= await CapabilityProfile.load();
    _generator = Generator(PaperSize.mm58, _profile!);
    return _generator!;
  }

  /// Pre-load logo, card image and generator while the page is opening
  /// so by the time the user taps Print, everything is already cached.
  static void preWarm(
      {required String photoUrl, required bool printCardImage}) {
    // Fire and forget — we don't need the results here
    _getGenerator();
    downloadAndDecodeImage('http://inteshar.net/logo-print.jpg');
    if (printCardImage && photoUrl.isNotEmpty) {
      downloadAndDecodeImage(photoUrl);
    }
  }

  static Future<ui.Image?> downloadAndDecodeImage(String url) async {
    if (url.isEmpty) return null;

    // Force HTTPS to bypass Android cleartext restrictions for network requests
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }

    // Check cache first
    if (url.contains('logo-print.jpg') && _logoImageCache != null) {
      return _logoImageCache;
    }
    if (_cardImageCache.containsKey(url)) {
      return _cardImageCache[url];
    }

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final codec = await ui.instantiateImageCodec(bytes);
        final frameInfo = await codec.getNextFrame();

        final image = frameInfo.image;
        if (url.contains('logo-print.jpg')) {
          _logoImageCache = image;
        } else {
          _cardImageCache[url] = image;
        }
        return image;
      }
    } catch (e) {
      debugPrint('Error downloading/decoding image ($url): $e');
    }
    return null;
  }

  static String removeHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  // Helper struct passed to the compute isolate
  // Fast direct RGBA to ESC/POS Raster command converter — runs in background isolate
  static List<int> _imageToRasterBytesSync(_RasterArgs args) {
    final Uint8List rgbaBytes = args.rgbaBytes;
    final int width = args.width;
    final int height = args.height;
    final int widthBytes = (width + 7) ~/ 8;

    // GS v 0 m xL xH yL yH + data
    final List<int> bytes = List<int>.filled(8 + widthBytes * height, 0);
    bytes[0] = 0x1D;
    bytes[1] = 0x76;
    bytes[2] = 0x30;
    bytes[3] = 0; // Normal Mode

    bytes[4] = widthBytes & 0xFF;
    bytes[5] = (widthBytes >> 8) & 0xFF;
    bytes[6] = height & 0xFF;
    bytes[7] = (height >> 8) & 0xFF;

    int writeIndex = 8;
    for (int y = 0; y < height; y++) {
      for (int xByte = 0; xByte < widthBytes; xByte++) {
        int byteVal = 0;
        for (int bit = 0; bit < 8; bit++) {
          final int x = (xByte << 3) + bit;
          if (x < width) {
            final int pixelIndex = ((y * width) + x) << 2;
            if (pixelIndex + 3 < rgbaBytes.length) {
              final int r = rgbaBytes[pixelIndex];
              final int g = rgbaBytes[pixelIndex + 1];
              final int b = rgbaBytes[pixelIndex + 2];
              final int a = rgbaBytes[pixelIndex + 3];

              if (a >= 128) {
                final double luminance = 0.299 * r + 0.587 * g + 0.114 * b;
                if (luminance < 200) {
                  byteVal |= (1 << (7 - bit));
                }
              }
            }
          }
        }
        bytes[writeIndex++] = byteVal;
      }
    }
    return bytes;
  }

  static Future<List<int>> _imageToRasterBytes(ui.Image imgUi) async {
    final byteData = await imgUi.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return [];

    final Uint8List rgbaBytes = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    // Offload the CPU-heavy pixel loop to a background isolate
    return compute(
      _imageToRasterBytesSync,
      _RasterArgs(
        rgbaBytes: rgbaBytes,
        width: imgUi.width,
        height: imgUi.height,
      ),
    );
  }

  static Future<List<int>> printSingleSerialTicket({
    required dynamic serial,
    required dynamic user,
    required dynamic purchaseData,
    required ui.Image? logoImage,
    required ui.Image? cardImage,
    required bool printCardImage,
    required bool printInfo,
    required bool printQrCode,
    required bool printBarcode,
    required Generator generator,
    required int index,
  }) async {
    const double ticketWidth = 384.0;
    double ticketHeight = 0.0;

    double logoHeight = 0.0;
    if (logoImage != null) {
      const double logoWidth = 220.0;
      logoHeight = (logoWidth / logoImage.width) * logoImage.height;
      ticketHeight += logoHeight + 10.0;
    }

    final String terminalName = user.user?.name ?? '';
    final String terminalId = "Terminal ID: ${user.user?.id ?? ''}";
    final String printTime = "Time: ${purchaseData.printDate}";
    final String orderNum = "Order Number: ${serial.id ?? ''}";
    final String expiryTime =
        "Expiry Time: ${serial.expiredDate ?? serial.code3 ?? ''}";

    final headerLines = [
      _TextLayout(terminalName, bold: true, fontSize: 26.0),
      _TextLayout("----------------------------", bold: false, fontSize: 26.0),
      _TextLayout(terminalId, bold: false, fontSize: 26.0),
      _TextLayout(printTime, bold: false, fontSize: 20.0),
      _TextLayout(orderNum, bold: false, fontSize: 26.0),
      _TextLayout(expiryTime, bold: false, fontSize: 26.0),
    ];

    double headerHeight = 0.0;
    for (var line in headerLines) {
      line.layout(ticketWidth);
      headerHeight += line.height + 6.0;
    }
    ticketHeight += headerHeight + 10.0;

    double cardImgHeight = 0.0;
    if (printCardImage && cardImage != null) {
      cardImgHeight = (ticketWidth / cardImage.width) * cardImage.height;
      ticketHeight += cardImgHeight + 10.0;
    }

    final cardTitle = purchaseData.cardTitle ?? '';
    final serialNum = "serial : ${serial.serial ?? ''}";
    final List<_TextLayout> detailLines = [];

    detailLines.add(_TextLayout(cardTitle, bold: true, fontSize: 26.0));
    detailLines.add(_TextLayout(serialNum, bold: false, fontSize: 26.0));

    if (serial.code != null && serial.code != '') {
      detailLines.add(_TextLayout("${serial.code}",
          bold: true, fontSize: 40.0, border: true));
    } else {
      if (serial.code1 != null && serial.code1 != '') {
        detailLines
            .add(_TextLayout("${serial.code1}", bold: false, fontSize: 26.0));
      }
      if (serial.code2 != null && serial.code2 != '') {
        detailLines.add(_TextLayout("${serial.code2}",
            bold: true, fontSize: 40.0, border: true));
      }
      if (serial.code3 != null && serial.code3 != '') {
        detailLines
            .add(_TextLayout("${serial.code3}", bold: false, fontSize: 26.0));
      }
      if (serial.code4 != null && serial.code4 != '') {
        detailLines
            .add(_TextLayout("${serial.code4}", bold: false, fontSize: 26.0));
      }
    }

    ui.Image? footerHtmlImage;
    if (printInfo) {
      final footerText = purchaseData.cardDetails2?.cardFooter ??
          purchaseData.cardDetails?.cardFooter ??
          '';
      if (footerText.isNotEmpty) {
        footerHtmlImage = await htmlToImage(footerText, ticketWidth);
        if (footerHtmlImage != null) {
          ticketHeight += footerHtmlImage.height + 10.0;
        }
      }
    }

    double detailsHeight = 0.0;
    for (var line in detailLines) {
      line.layout(ticketWidth);
      detailsHeight += line.height + 6.0;
    }
    ticketHeight += detailsHeight + 10.0;

    QrPainter? qrPainter;
    const double qrSize = 100.0;
    if (printQrCode &&
        purchaseData.ussdCodes != null &&
        purchaseData.ussdCodes!.length > index &&
        purchaseData.ussdCodes![index].code != null) {
      final ussdCode = purchaseData.ussdCodes![index].code;
      qrPainter = QrPainter(
        data: "tel:$ussdCode",
        version: QrVersions.auto,
        gapless: true,
        color: const ui.Color(0xFF000000),
        emptyColor: const ui.Color(0xFFFFFFFF),
      );
      ticketHeight += qrSize + 10.0;
    }

    ui.Picture? barcodePicture;
    const double barcodeHeight = 80.0;
    const double barcodeWidth = 300.0;
    if (printBarcode) {
      final cardIdString =
          '00964${purchaseData.cardCategory?.id?.toString() ?? ''}';
      final barcode = bc.Barcode.code93();
      final svgString = barcode.toSvg(cardIdString,
          width: barcodeWidth, height: barcodeHeight);
      final pictureInfo =
          await vg.loadPicture(SvgStringLoader(svgString), null);
      barcodePicture = pictureInfo.picture;
      ticketHeight += barcodeHeight + 10.0;
    }

    ticketHeight += 30.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, ticketWidth, ticketHeight), bgPaint);

    double currentY = 0.0;

    if (logoImage != null) {
      const double logoWidth = 220.0;
      const double dx = (ticketWidth - logoWidth) / 2;
      canvas.drawImageRect(
        logoImage,
        Rect.fromLTWH(
            0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
        Rect.fromLTWH(dx, currentY, logoWidth, logoHeight),
        Paint(),
      );
      currentY += logoHeight + 10.0;
    }

    for (var line in headerLines) {
      line.paint(canvas, currentY, ticketWidth);
      currentY += line.height + 6.0;
    }
    currentY += 10.0;

    if (printCardImage && cardImage != null) {
      canvas.drawImageRect(
        cardImage,
        Rect.fromLTWH(
            0, 0, cardImage.width.toDouble(), cardImage.height.toDouble()),
        Rect.fromLTWH(0, currentY, ticketWidth, cardImgHeight),
        Paint(),
      );
      currentY += cardImgHeight + 10.0;
    }

    for (var line in detailLines) {
      line.paint(canvas, currentY, ticketWidth);
      currentY += line.height + 6.0;
    }
    currentY += 10.0;

    if (footerHtmlImage != null) {
      canvas.drawImage(footerHtmlImage, Offset(0, currentY), Paint());
      currentY += footerHtmlImage.height + 10.0;
    }

    if (qrPainter != null) {
      canvas.save();
      canvas.translate((ticketWidth - qrSize) / 2, currentY);
      qrPainter.paint(canvas, const Size(qrSize, qrSize));
      canvas.restore();
      currentY += qrSize + 10.0;
    }

    if (barcodePicture != null) {
      canvas.save();
      canvas.translate((ticketWidth - barcodeWidth) / 2, currentY);
      canvas.drawPicture(barcodePicture);
      canvas.restore();
      currentY += barcodeHeight + 10.0;
    }

    final picture = recorder.endRecording();
    final imgUi =
        await picture.toImage(ticketWidth.toInt(), ticketHeight.toInt());

    // Call our highly optimized direct RGBA to ESC/POS Raster command encoder
    return await _imageToRasterBytes(imgUi);
  }

  static Future<List<int>> printSingleSerialTicketRaw({
    required dynamic serial,
    required dynamic user,
    required String cardTitle,
    required String printDate,
    required String footer,
    required List ussdCodes,
    required String cardId,
    required ui.Image? logoImage,
    required ui.Image? cardImage,
    required bool printCardImage,
    required bool printInfo,
    required bool printQrCode,
    required bool printBarcode,
    required int index,
    required bool isReported,
  }) async {
    const double ticketWidth = 384.0;
    double ticketHeight = 0.0;

    double logoHeight = 0.0;
    if (logoImage != null) {
      const double logoWidth = 220.0;
      logoHeight = (logoWidth / logoImage.width) * logoImage.height;
      ticketHeight += logoHeight + 10.0;
    }

    final String terminalName = user.user?.name ?? '';
    final String terminalId = "Terminal ID: ${user.user?.id ?? ''}";
    final String printTime = "Time: $printDate";
    final String orderNum = "Order Number: ${serial.id ?? ''}";
    final String expiryTime =
        "Expiry Time: ${serial.expiredDate ?? serial.code3 ?? ''}";

    final headerLines = [
      if (isReported)
        _TextLayout('--------- 2 ---------', bold: false, fontSize: 26.0),
      _TextLayout(terminalName, bold: true, fontSize: 26.0),
      _TextLayout("----------------------------", bold: false, fontSize: 26.0),
      _TextLayout(terminalId, bold: false, fontSize: 26.0),
      _TextLayout(printTime, bold: false, fontSize: 20.0),
      _TextLayout(orderNum, bold: false, fontSize: 26.0),
      _TextLayout(expiryTime, bold: false, fontSize: 26.0),
    ];

    double headerHeight = 0.0;
    for (var line in headerLines) {
      line.layout(ticketWidth);
      headerHeight += line.height + 6.0;
    }
    ticketHeight += headerHeight + 10.0;

    double cardImgHeight = 0.0;
    if (printCardImage && cardImage != null) {
      cardImgHeight = (ticketWidth / cardImage.width) * cardImage.height;
      ticketHeight += cardImgHeight + 10.0;
    }

    final serialNum = "serial : ${serial.serial ?? ''}";
    final List<_TextLayout> detailLines = [];

    detailLines.add(_TextLayout(cardTitle, bold: true, fontSize: 26.0));
    detailLines.add(_TextLayout(serialNum, bold: false, fontSize: 26.0));

    if (serial.code != null && serial.code != '') {
      detailLines.add(_TextLayout("${serial.code}",
          bold: true, fontSize: 40.0, border: true));
    } else {
      if (serial.code1 != null && serial.code1 != '') {
        detailLines
            .add(_TextLayout("${serial.code1}", bold: false, fontSize: 26.0));
      }
      if (serial.code2 != null && serial.code2 != '') {
        detailLines.add(_TextLayout("${serial.code2}",
            bold: true, fontSize: 40.0, border: true));
      }
      if (serial.code3 != null && serial.code3 != '') {
        detailLines
            .add(_TextLayout("${serial.code3}", bold: false, fontSize: 26.0));
      }
      if (serial.code4 != null && serial.code4 != '') {
        detailLines
            .add(_TextLayout("${serial.code4}", bold: false, fontSize: 26.0));
      }
    }

    ui.Image? footerHtmlImage;
    if (printInfo) {
      final footerText = footer;
      if (footerText.isNotEmpty) {
        footerHtmlImage = await htmlToImage(footerText, ticketWidth);
        if (footerHtmlImage != null) {
          ticketHeight += footerHtmlImage.height + 10.0;
        }
      }
    }

    double detailsHeight = 0.0;
    for (var line in detailLines) {
      line.layout(ticketWidth);
      detailsHeight += line.height + 6.0;
    }
    ticketHeight += detailsHeight + 10.0;

    QrPainter? qrPainter;
    const double qrSize = 100.0;
    if (printQrCode &&
        ussdCodes.length > index &&
        ussdCodes[index]?.code != null) {
      final ussdCode = ussdCodes[index].code;
      qrPainter = QrPainter(
        data: "tel:$ussdCode",
        version: QrVersions.auto,
        gapless: true,
        color: const ui.Color(0xFF000000),
        emptyColor: const ui.Color(0xFFFFFFFF),
      );
      ticketHeight += qrSize + 10.0;
    }

    ui.Picture? barcodePicture;
    const double barcodeHeight = 80.0;
    const double barcodeWidth = 300.0;
    if (printBarcode) {
      final cardIdString = '00964$cardId';
      final barcode = bc.Barcode.code93();
      final svgString = barcode.toSvg(cardIdString,
          width: barcodeWidth, height: barcodeHeight);
      final pictureInfo =
          await vg.loadPicture(SvgStringLoader(svgString), null);
      barcodePicture = pictureInfo.picture;
      ticketHeight += barcodeHeight + 10.0;
    }

    ticketHeight += 30.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, ticketWidth, ticketHeight), bgPaint);

    double currentY = 0.0;

    if (logoImage != null) {
      const double logoWidth = 220.0;
      const double dx = (ticketWidth - logoWidth) / 2;
      canvas.drawImageRect(
        logoImage,
        Rect.fromLTWH(
            0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
        Rect.fromLTWH(dx, currentY, logoWidth, logoHeight),
        Paint(),
      );
      currentY += logoHeight + 10.0;
    }

    for (var line in headerLines) {
      line.paint(canvas, currentY, ticketWidth);
      currentY += line.height + 6.0;
    }
    currentY += 10.0;

    if (printCardImage && cardImage != null) {
      canvas.drawImageRect(
        cardImage,
        Rect.fromLTWH(
            0, 0, cardImage.width.toDouble(), cardImage.height.toDouble()),
        Rect.fromLTWH(0, currentY, ticketWidth, cardImgHeight),
        Paint(),
      );
      currentY += cardImgHeight + 10.0;
    }

    for (var line in detailLines) {
      line.paint(canvas, currentY, ticketWidth);
      currentY += line.height + 6.0;
    }
    currentY += 10.0;

    if (footerHtmlImage != null) {
      canvas.drawImage(footerHtmlImage, Offset(0, currentY), Paint());
      currentY += footerHtmlImage.height + 10.0;
    }

    if (qrPainter != null) {
      canvas.save();
      canvas.translate((ticketWidth - qrSize) / 2, currentY);
      qrPainter.paint(canvas, const Size(qrSize, qrSize));
      canvas.restore();
      currentY += qrSize + 10.0;
    }

    if (barcodePicture != null) {
      canvas.save();
      canvas.translate((ticketWidth - barcodeWidth) / 2, currentY);
      canvas.drawPicture(barcodePicture);
      canvas.restore();
      currentY += barcodeHeight + 10.0;
    }

    final picture = recorder.endRecording();
    final imgUi =
        await picture.toImage(ticketWidth.toInt(), ticketHeight.toInt());

    return await _imageToRasterBytes(imgUi);
  }

  static Future<bool> printTickets({
    required List serials,
    required dynamic user,
    required dynamic purchaseData,
    required bool printCardImage,
    required bool printInfo,
    required bool printQrCode,
    required bool printBarcode,
    required String photoUrl,
  }) async {
    try {
      // Parallel download/cache retrieval
      final logoFuture =
          downloadAndDecodeImage('http://inteshar.net/logo-print.jpg');
      final cardPhotoFuture = (printCardImage && photoUrl.isNotEmpty)
          ? downloadAndDecodeImage(photoUrl)
          : Future.value(null);

      final decodedImages = await Future.wait([logoFuture, cardPhotoFuture]);
      final ui.Image? logoImage = decodedImages[0];
      final ui.Image? cardImage = decodedImages[1];

      final List<Future<List<int>>> ticketFutures = [];
      for (int i = 0; i < serials.length; i++) {
        ticketFutures.add(
          printSingleSerialTicket(
            serial: serials[i],
            user: user,
            purchaseData: purchaseData,
            logoImage: logoImage,
            cardImage: cardImage,
            printCardImage: printCardImage,
            printInfo: printInfo,
            printQrCode: printQrCode,
            printBarcode: printBarcode,
            generator: await _getGenerator(),
            index: i,
          ),
        );
      }

      final List<List<int>> ticketsBytes = await Future.wait(ticketFutures);

      final List<int> allBytes = [];
      for (var bytes in ticketsBytes) {
        allBytes.addAll(bytes);
      }

      if (allBytes.isNotEmpty) {
        return await PrintBluetoothThermal.writeBytes(allBytes);
      }
    } catch (e) {
      debugPrint('Error compiling and printing tickets: $e');
    }
    return false;
  }

  static Future<bool> printTicketsRaw({
    required List serials,
    required dynamic user,
    required String cardTitle,
    required String photoUrl,
    required List ussdCodes,
    required String printDate,
    required String footer,
    required String cardId,
    required bool printCardImage,
    required bool printInfo,
    required bool printQrCode,
    required bool printBarcode,
    required bool isReported,
  }) async {
    try {
      final logoFuture =
          downloadAndDecodeImage('http://inteshar.net/logo-print.jpg');
      final cardPhotoFuture = (printCardImage && photoUrl.isNotEmpty)
          ? downloadAndDecodeImage(photoUrl)
          : Future.value(null);

      final decodedImages = await Future.wait([logoFuture, cardPhotoFuture]);
      final ui.Image? logoImage = decodedImages[0];
      final ui.Image? cardImage = decodedImages[1];

      final List<Future<List<int>>> ticketFutures = [];
      for (int i = 0; i < serials.length; i++) {
        ticketFutures.add(
          printSingleSerialTicketRaw(
            serial: serials[i],
            user: user,
            cardTitle: cardTitle,
            printDate: printDate,
            footer: footer,
            ussdCodes: ussdCodes,
            cardId: cardId,
            logoImage: logoImage,
            cardImage: cardImage,
            printCardImage: printCardImage,
            printInfo: printInfo,
            printQrCode: printQrCode,
            printBarcode: printBarcode,
            index: i,
            isReported: isReported,
          ),
        );
      }

      final List<List<int>> ticketsBytes = await Future.wait(ticketFutures);

      final List<int> allBytes = [];
      for (var bytes in ticketsBytes) {
        allBytes.addAll(bytes);
      }

      if (allBytes.isNotEmpty) {
        return await PrintBluetoothThermal.writeBytes(allBytes);
      }
    } catch (e) {
      debugPrint('Error in printTicketsRaw: $e');
    }
    return false;
  }
}

class _TextLayout {
  final String text;
  final bool bold;
  final double fontSize;
  final bool border;

  late TextPainter _tp;

  _TextLayout(this.text,
      {required this.bold, required this.fontSize, this.border = false});

  void layout(double maxWidth) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      fontFamily: 'dijlah',
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
    );
    _tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
    _tp.layout(maxWidth: maxWidth);
  }

  double get height => _tp.height;

  void paint(Canvas canvas, double yOffset, double width) {
    final dx = (width - _tp.width) / 2;
    _tp.paint(canvas, Offset(dx, yOffset));

    if (border) {
      final paint = Paint()
        ..color = const ui.Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(dx - 6, yOffset - 2, _tp.width + 12, _tp.height + 4),
        const Radius.circular(6),
      );
      canvas.drawRRect(rrect, paint);
    }
  }
}

/// Data class passed to the background isolate for raster conversion
class _RasterArgs {
  final Uint8List rgbaBytes;
  final int width;
  final int height;

  const _RasterArgs({
    required this.rgbaBytes,
    required this.width,
    required this.height,
  });
}

Future<ui.Image?> htmlToImage(String htmlContent, double width) async {
  if (htmlContent.isEmpty) return null;

  // Convert pt to px and scale it for better print readability
  final processedHtml = htmlContent.replaceAllMapped(
    RegExp(r'(\d+)\s*pt', caseSensitive: false),
    (match) {
      final val = int.tryParse(match.group(1) ?? '') ?? 12;
      return '${(val * 2.2).toInt()}px';
    },
  );

  final screenshotController = ScreenshotController();
  final widget = Container(
    color: Colors.white,
    width: width,
    padding: const EdgeInsets.all(5),
    child: Html(
      data: processedHtml,
      style: {
        "p": Style(
          fontSize: FontSize(16),
          color: Colors.black,
        ),
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          color: Colors.black,
        ),
      },
    ),
  );

  try {
    final Uint8List pngBytes = await screenshotController.captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 50),
      context: Get.context,
      pixelRatio: 1.0,
    );

    final codec = await ui.instantiateImageCodec(pngBytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  } catch (e) {
    debugPrint("Error rendering HTML to ui.Image: $e");
    return null;
  }
}
