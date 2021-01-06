import 'dart:ui';

class SettingsComboTileData<T> {
  final String titleText;
  final Color subtitleColor;
  final T initialSelection;
  final List<T> options;
  final String textFieldText;
  final String detailsHtml;

  SettingsComboTileData(
      {this.titleText,
      this.subtitleColor,
      this.initialSelection,
      this.options,
      this.textFieldText,
      this.detailsHtml});
}
