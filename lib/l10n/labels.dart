import '../models/age_band.dart';
import '../models/category.dart';
import 'app_localizations.dart';
import 'ja_styles.dart';

String categoryLabel(AppLocalizations l, String category) => switch (category) {
      'animals' => l.catAnimals,
      'space' => l.catSpace,
      'body' => l.catBody,
      'nature' => l.catNature,
      'science' => l.catScience,
      'geography' => l.catGeography,
      'bugs' => l.catBugs,
      'vehicles' => l.catVehicles,
      'food' => l.catFood,
      _ => _dataCategoryLabel(l, category),
    };

/// ARB にないカテゴリー（categories.json で足したもの）の名前。
String _dataCategoryLabel(AppLocalizations l, String id) {
  final c = CategoryRegistry.get(id);
  if (c == null) return id;
  final style = l is AppLocalizationsJaJunior
      ? 'junior'
      : (l is AppLocalizationsJaAdult ? 'adult' : 'kids');
  return c.label(l.localeName, style: style);
}

String sceneLabel(AppLocalizations l, String scene) => switch (scene) {
      'friends' => l.sceneFriends,
      'kids' => l.sceneKids,
      'work' => l.sceneWork,
      'family' => l.sceneFamily,
      'learning' => l.sceneLearning,
      _ => scene,
    };

String modeLabel(AppLocalizations l, AgeBand band) => switch (band) {
      AgeBand.kids => l.modeKids,
      AgeBand.junior => l.modeJunior,
      AgeBand.teen => l.modeTeen,
      AgeBand.adult => l.modeAdult,
    };

const allScenes = ['friends', 'kids', 'work', 'family', 'learning'];
