import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:freehub/services/share_intent_service.dart';

class MockReceiveSharingIntent extends ReceiveSharingIntent {
  final List<SharedMediaFile> _initialMedia;
  final StreamController<List<SharedMediaFile>> _streamController;
  bool resetCalled = false;

  MockReceiveSharingIntent({
    List<SharedMediaFile>? initialMedia,
    StreamController<List<SharedMediaFile>>? streamController,
  })  : _initialMedia = initialMedia ?? [],
        _streamController =
            streamController ?? StreamController<List<SharedMediaFile>>.broadcast();

  @override
  Future<List<SharedMediaFile>> getInitialMedia() async {
    return _initialMedia;
  }

  @override
  Stream<List<SharedMediaFile>> getMediaStream() {
    return _streamController.stream;
  }

  @override
  Future<dynamic> reset() async {
    resetCalled = true;
  }
}

void main() {
  group('ShareIntentService.parseSharedText Tests', () {
    test('extracts clean URL from plain URL text', () {
      final parsed = ShareIntentService.parseSharedText('https://flutter.dev');
      expect(parsed, isNotNull);
      expect(parsed!.url, equals('https://flutter.dev'));
      expect(parsed.suggestedTitle, equals('Flutter'));
    });

    test('extracts URL and title from title + URL string (Chrome style)', () {
      const raw = 'Photopea | Online Photo Editor\nhttps://www.photopea.com';
      final parsed = ShareIntentService.parseSharedText(raw);
      expect(parsed, isNotNull);
      expect(parsed!.url, equals('https://www.photopea.com'));
      expect(parsed.suggestedTitle, equals('Photopea | Online Photo Editor'));
    });

    test('extracts URL with trailing punctuation cleaned', () {
      const raw = 'Check out this website: https://github.com/trending.';
      final parsed = ShareIntentService.parseSharedText(raw);
      expect(parsed, isNotNull);
      expect(parsed!.url, equals('https://github.com/trending'));
    });

    test('extracts URL embedded in promotional share text', () {
      const raw = 'Check this out: "Hugging Face" - https://huggingface.co/models';
      final parsed = ShareIntentService.parseSharedText(raw);
      expect(parsed, isNotNull);
      expect(parsed!.url, equals('https://huggingface.co/models'));
      expect(parsed.suggestedTitle, contains('Hugging Face'));
    });

    test('handles naked domains correctly', () {
      final parsed = ShareIntentService.parseSharedText('reddit.com');
      expect(parsed, isNotNull);
      expect(parsed!.url, equals('https://reddit.com'));
      expect(parsed.suggestedTitle, equals('Reddit'));
    });

    test('returns null for plain non-URL text', () {
      final parsed = ShareIntentService.parseSharedText('Hello world, no link here');
      expect(parsed, isNull);
    });

    test('returns null for empty string', () {
      final parsed = ShareIntentService.parseSharedText('   ');
      expect(parsed, isNull);
    });
  });

  group('ShareIntentService Listener Integration Tests', () {
    test('handles warm/hot start stream events', () async {
      final streamController =
          StreamController<List<SharedMediaFile>>.broadcast();
      final mockPlugin = MockReceiveSharingIntent(
        streamController: streamController,
      );

      final service = ShareIntentService();
      final receivedData = <ParsedSharedData>[];

      service.initSharingListener(
        onDataReceived: (data) {
          receivedData.add(data);
        },
        pluginInstance: mockPlugin,
      );

      // Emit a shared link
      streamController.add([
        SharedMediaFile(
          path: 'Awesome Tool\nhttps://awesome-tool.com',
          type: SharedMediaType.text,
        ),
      ]);

      // Allow event loop to process
      await pumpEventQueue();

      expect(receivedData.length, equals(1));
      expect(receivedData.first.url, equals('https://awesome-tool.com'));
      expect(receivedData.first.suggestedTitle, equals('Awesome Tool'));
      expect(mockPlugin.resetCalled, isTrue);

      service.dispose();
      await streamController.close();
    });

    test('handles cold start initial media events', () async {
      final mockPlugin = MockReceiveSharingIntent(
        initialMedia: [
          SharedMediaFile(
            path: 'https://deepseek.com',
            type: SharedMediaType.url,
          ),
        ],
      );

      final service = ShareIntentService();
      final receivedData = <ParsedSharedData>[];

      service.initSharingListener(
        onDataReceived: (data) {
          receivedData.add(data);
        },
        pluginInstance: mockPlugin,
      );

      await pumpEventQueue();

      expect(receivedData.length, equals(1));
      expect(receivedData.first.url, equals('https://deepseek.com'));
      expect(receivedData.first.suggestedTitle, equals('Deepseek'));
      expect(mockPlugin.resetCalled, isTrue);

      service.dispose();
    });
  });
}
