import 'package:flutter_test/flutter_test.dart';
import 'package:notes/components/components.dart';
import 'package:notes/constants.dart';

void main() {
  final utils = ComponentUtils();

  group('ComponentUtils Style Methods', () {
    test('getBasicTextStyle - simple test', () {
      final style = utils.getBasicTextStyle();

      expect(style.fontSize, DEFAULT_TEXT_SIZE);
    });

    /*test('getButtonStyle - simple test', () {
      final buttonStyle = utils.getButtonStyle();

      expect(buttonStyle.shape.resolve({}).dimensions, BorderRadius.circular(BUTTON_BORDER_RADIUS));
    });*/
  });
}
