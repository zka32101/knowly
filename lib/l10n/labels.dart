import '../models/age_band.dart';
import 'app_localizations.dart';

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
      _ => category,
    };

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

const allCategories = [
  'animals', 'bugs', 'vehicles', 'food', 'space', 'body', 'nature', 'science', 'geography',
];
const allScenes = ['friends', 'kids', 'work', 'family', 'learning'];
