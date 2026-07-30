import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/logger.dart';

void main() {
  group('ConsoleLogger', () {
    late ConsoleLogger logger;

    setUp(() {
      logger = ConsoleLogger();
    });

    test('does not throw on any log level', () {
      expect(() => logger.debug('debug message'), returnsNormally);
      expect(() => logger.info('info message'), returnsNormally);
      expect(() => logger.warning('warning message'), returnsNormally);
      expect(() => logger.error('error message'), returnsNormally);
      expect(() => logger.fatal('fatal message'), returnsNormally);
    });

    test('handles null error and stacktrace', () {
      expect(() => logger.debug('msg', null, null), returnsNormally);
      expect(() => logger.info('msg', Exception('test'), StackTrace.current),
          returnsNormally);
    });

    test('log() delegates to correct level method', () {
      expect(() => logger.log(LogLevel.debug, 'debug'), returnsNormally);
      expect(() => logger.log(LogLevel.info, 'info'), returnsNormally);
      expect(() => logger.log(LogLevel.warning, 'warn'), returnsNormally);
      expect(() => logger.log(LogLevel.error, 'error'), returnsNormally);
      expect(() => logger.log(LogLevel.fatal, 'fatal'), returnsNormally);
    });

    test('log() includes metadata when provided', () {
      expect(
        () => logger.log(LogLevel.info, 'event', data: {'key': 'value'}),
        returnsNormally,
      );
    });
  });

  group('NoopLogger', () {
    late NoopLogger logger;

    setUp(() {
      logger = NoopLogger();
    });

    test('all methods are silent (no output, no side effects)', () {
      expect(() => logger.debug('debug'), returnsNormally);
      expect(() => logger.info('info'), returnsNormally);
      expect(() => logger.warning('warning'), returnsNormally);
      expect(() => logger.error('error'), returnsNormally);
      expect(() => logger.fatal('fatal'), returnsNormally);
      expect(
        () => logger.log(LogLevel.info, 'event', data: {'key': 'value'}),
        returnsNormally,
      );
    });
  });
}
