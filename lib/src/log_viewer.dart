import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LogViewerScreen extends StatefulWidget {
  final String fileName;

  const LogViewerScreen({
    super.key,
    required this.fileName,
  });

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final TextStyle normalStyle = const TextStyle(color: Colors.black);
  final List<TextSpan> textSpans = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _textKey = GlobalKey();

  bool isLoading = false;
  int chunkSize = 2048 * 2; // Size of each chunk in bytes
  int currentIndex = 0; // Current read position in the file
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Log Viewer'),
          actions: [
            TextButton(
              onPressed: () {
                _loadAllData();
              },
              child: const Text('Go to Bottom'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: RichText(
                    key: _textKey,
                    text: TextSpan(
                      children: [...textSpans],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 7,
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      _loadMoreData();
    }
  }

  Future<void> _loadAllData() async {
    while (isLoading || currentIndex < await _getFileSize(widget.fileName)) {
      await _loadMoreData();
    }
    _scrollToBottom();
  }

  void _scrollToBottom() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _loadMoreData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    _loadingTimer = Timer(const Duration(seconds: 3), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    });

    await for (String chunk
        in _streamFile(currentIndex, chunkSize, fileName: widget.fileName)) {
      if (chunk.isNotEmpty) {
        setState(() {
          textSpans.add(TextSpan(
              text: chunk,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface)));
          currentIndex += chunkSize;
        });

        // Check if the content height is less than the screen height and load more data if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = _textKey.currentContext;
          if (context != null) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final double contentHeight = box.size.height;
            final double screenHeight = MediaQuery.of(context).size.height;

            if (contentHeight < screenHeight) {
              _loadMoreData();
            }
          }
        });
      }
    }

    setState(() {
      isLoading = false;
    });

    if (_loadingTimer?.isActive ?? false) {
      _loadingTimer?.cancel();
    }
  }

  Stream<String> _streamFile(
    int startIndex,
    int chunkSize, {
    required String fileName,
  }) async* {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    RandomAccessFile raf = await file.open();
    int fileSize = await raf.length();
    int endIndex = startIndex + chunkSize;

    endIndex = endIndex > fileSize ? fileSize : endIndex;

    raf.setPositionSync(startIndex);
    List<int> chunk = raf.readSync(endIndex - startIndex);
    raf.closeSync();

    // Ensure proper decoding
    yield utf8.decode(chunk, allowMalformed: true);
  }

  Future<int> _getFileSize(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.length();
  }
}
