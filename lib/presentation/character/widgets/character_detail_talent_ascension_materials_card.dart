import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/common_table_cell.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/images/wrapped_ascension_material.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CharacterDetailTalentAscensionMaterialsCard extends StatelessWidget {
  final ElementType elementType;
  final List<CharacterTalentAscensionModel> talentAscensionMaterials;
  final List<CharacterMultiTalentAscensionModel> multiTalentAscensionMaterials;

  const CharacterDetailTalentAscensionMaterialsCard.withTalents({
    Key? key,
    required this.elementType,
    required this.talentAscensionMaterials,
  })  : multiTalentAscensionMaterials = const [],
        super(key: key);

  const CharacterDetailTalentAscensionMaterialsCard.withMultiTalents({
    Key? key,
    required this.elementType,
    required this.multiTalentAscensionMaterials,
  })  : talentAscensionMaterials = const [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (talentAscensionMaterials.isNotEmpty) {
      return _buildTableCard(s.talentsAscension, talentAscensionMaterials, context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [...multiTalentAscensionMaterials.map((e) => _buildTableCard(s.talentAscensionX(e.number), e.materials, context)).toList()],
    );
  }

  Widget _buildTableCard(
    String title,
    List<CharacterTalentAscensionModel> materials,
    BuildContext context,
  ) {
    final s = S.of(context);
    final body = Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetVertical5,
        child: Table(
          columnWidths: const {
            0: FractionColumnWidth(.2),
            1: FractionColumnWidth(.8),
          },
          children: [
            TableRow(
              children: [
                CommonTableCell(text: s.level, padding: Styles.edgeInsetAll10),
                CommonTableCell(text: s.materials, padding: Styles.edgeInsetAll10),
              ],
            ),
            ...materials.map((e) => _buildTalentAscensionRow(e)).toList(),
          ],
        ),
      ),
    );

    return ItemDescriptionDetail(
      title: title,
      body: body,
      textColor: elementType.getElementColorFromContext(context),
    );
  }

  TableRow _buildTalentAscensionRow(CharacterTalentAscensionModel model) {
    final materials = model.materials.map((m) => WrappedAscensionMaterial(itemKey: m.key, image: m.image, quantity: m.quantity)).toList();
    return TableRow(
      children: [
        CommonTableCell(
          text: '${model.level}',
          padding: Styles.edgeInsetAll10,
        ),
        CommonTableCell.child(
          child: Wrap(alignment: WrapAlignment.center, children: materials),
        ),
      ],
    );
  }
}
