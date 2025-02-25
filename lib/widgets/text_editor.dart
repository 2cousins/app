import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:two_cousins/utils/theming/app_flowy/block_component_builder.dart';
import 'package:two_cousins/utils/theming/app_flowy/character_shortcut_events.dart';
import 'package:two_cousins/utils/theming/app_flowy/mobile_toolbar_items.dart';
import 'package:two_cousins/utils/plugins/inline_math_equation/inline_math_equation_toolbar_item.dart';

import '../utils/plugins/inline_math_equation/inline_math_equation.dart';

class TextEditor extends StatelessWidget {
  const TextEditor(
      {super.key,
      required this.editorState,
      required this.readOnly,
      required this.padding,
      required this.desktop,
      this.header,
      this.footer});

  final EditorState editorState;
  final bool readOnly;
  final EdgeInsets? padding;
  final bool desktop;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return SingleChildScrollView(
        child: IntrinsicHeight(
          child: AppFlowyEditor(
              autoFocus: true,
              editable: false,
              shrinkWrap: true,
              header: header,
              footer: footer,
              focusNode: FocusNode(),
              editorState: editorState,
              blockComponentBuilders:
                  getCustomBlockComponentBuilderMap(context, editorState),
              characterShortcutEvents:
                  getCustomCharacterShortcutEvents(context),
              commandShortcutEvents: standardCommandShortcutEvents,
              editorStyle: const EditorStyle.desktop().copyWith(
                  padding: padding,
                  cursorColor: Theme.of(context).colorScheme.primary,
                  textStyleConfiguration: TextStyleConfiguration(
                      text: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  )))),
        ),
      );
    } else {
      if (desktop) {
        return FloatingToolbar(
          items: [
            paragraphItem,
            ...headingItems,
            ...markdownFormatItems,
            quoteItem,
            bulletedListItem,
            numberedListItem,
            inlineMathEquationItem,
            linkItem,
            buildTextColorItem(),
            buildHighlightColorItem()
          ],
          style: FloatingToolbarStyle(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Theme.of(context).cardColor,
            toolbarActiveColor: Theme.of(context).colorScheme.primary,
          ),
          editorState: editorState,
          editorScrollController: EditorScrollController(editorState: editorState),
          child: Expanded(
            child: AppFlowyEditor(
              autoFocus: true,
              focusNode: FocusNode(),
              editorState: editorState,
              blockComponentBuilders:
                  getCustomBlockComponentBuilderMap(context, editorState),
              characterShortcutEvents:
                  getCustomCharacterShortcutEvents(context),
              commandShortcutEvents: standardCommandShortcutEvents,
              editorStyle: const EditorStyle.desktop().copyWith(
                textSpanDecorator: customiseAttributeDecorator,
                padding: padding,
                cursorColor: Theme.of(context).colorScheme.primary,
                textStyleConfiguration: TextStyleConfiguration(
                  text: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  ),
                  href: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: AppFlowyEditor(
                  autoFocus: true,
                  focusNode: FocusNode(),
                  editorState: editorState,
                  blockComponentBuilders:
                      getCustomBlockComponentBuilderMap(context, editorState),
                  characterShortcutEvents:
                      getCustomCharacterShortcutEvents(context),
                  commandShortcutEvents: standardCommandShortcutEvents,
                  editorStyle: const EditorStyle.mobile().copyWith(
                    padding: padding,
                    cursorColor: Theme.of(context).colorScheme.primary,
                    textStyleConfiguration: TextStyleConfiguration(
                      text: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      href: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              MobileToolbar(
                editorState: editorState,
                backgroundColor: Theme.of(context).cardColor,
                tabbarSelectedForegroundColor: Theme.of(context).primaryColorLight,
                tabbarSelectedBackgroundColor: Colors.black26.withAlpha(50),
                foregroundColor: Theme.of(context).primaryColorLight.withAlpha(180),
                clearDiagonalLineColor: Theme.of(context).colorScheme.primary,
                itemOutlineColor: Theme.of(context).cardColor,
                itemHighlightColor: Theme.of(context).colorScheme.primary,
                toolbarItems: getMobileToolbarItems(Theme.of(context).primaryColorLight),
              )
            ],
          ),
        );
      }
    }
  }
}

InlineSpan customiseAttributeDecorator(
    BuildContext context,
    Node node,
    int index,
    TextInsert text,
    TextSpan textSpan,
    ) {
  final attributes = text.attributes;
  if (attributes == null) {
    return textSpan;
  }

  // customize the inline math equation block
  final formula = attributes[InlineMathEquationKeys.formula] as String?;
  if (formula != null) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: InlineMathEquation(
        node: node,
        index: index,
        formula: formula,
        textStyle: TextStyle(
          color: Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }

  return textSpan;
}
