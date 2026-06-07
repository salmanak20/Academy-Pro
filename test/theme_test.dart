import 'package:flutter_test/flutter_test.dart';
import 'package:academy_pro/core/theme/app_theme.dart';

void main() {
  test('darkTheme does not throw', () {
    expect(AppTheme.darkTheme, isNotNull);
  });
  test('lightTheme does not throw', () {
    expect(AppTheme.lightTheme, isNotNull);
  });
}
