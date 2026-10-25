// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Knowly';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Del dispositivo';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get continueButton => 'Siguiente';

  @override
  String get worldAskTitle => 'Personas de todo el mundo también lo leen';

  @override
  String get worldAskBody =>
      'Mira cuántas personas vieron este dato hoy y desde cuántos países. Solo se envía el ID del dato, el país y la fecha, sin nombre ni cuenta.';

  @override
  String get worldJoin => 'Participar';

  @override
  String get worldNotNow => 'Ahora no';

  @override
  String worldToday(int total, int countries) {
    return 'Hoy lo leyeron $total personas de $countries países';
  }

  @override
  String get settingsWorld => 'Participar en estadísticas mundiales';

  @override
  String get settingsWorldNote =>
      'Comparte de forma anónima cuántas personas leyeron los datos de hoy (puedes desactivarlo cuando quieras)';

  @override
  String reportThisWeek(int seen, int answered) {
    return 'Esta semana: $seen datos vistos, $answered preguntas respondidas';
  }

  @override
  String get settingsJuniorRuby => 'Mostrar lecturas (furigana)';

  @override
  String get listenSlow => 'Lenta';

  @override
  String get settingsTextSize => 'Tamaño del texto';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Grande';

  @override
  String get textSizeXLarge => 'Muy grande';

  @override
  String relatedMore(int n) {
    return 'Ver más ($n más)';
  }

  @override
  String get searchRecent => 'Recientes';

  @override
  String get hintHomeTips =>
      'Toca una tarjeta para girarla. ¡En «Jugar» hay quizzes!';

  @override
  String get hintGotIt => 'Entendido';

  @override
  String get onboardingSkip => 'Más tarde';

  @override
  String get onboardingPickBand => 'O elige lo que mejor te encaje';

  @override
  String get birthYearTitle => 'Elige tu año de nacimiento';

  @override
  String get birthYearNote =>
      'Solo se usa para adaptar el contenido a tu edad. Tu año de nacimiento no se guarda ni se envía a ninguna parte.';

  @override
  String get parentNoteTitle => 'Para los padres';

  @override
  String get parentNoteBody =>
      'Usa esta app junto con tu hijo o hija. No recoge información personal de los niños y no muestra anuncios.';

  @override
  String get modeKids => 'Kids (preescolar)';

  @override
  String get modeJunior => 'Junior (primaria)';

  @override
  String get modeTeen => 'Teen (adolescentes)';

  @override
  String get modeAdult => 'Adult (adultos)';

  @override
  String get interestsTitle => 'Elige lo que te gusta';

  @override
  String get interestsAll => 'Todo';

  @override
  String get catAnimals => 'Animales';

  @override
  String get catSpace => 'Espacio';

  @override
  String get catBody => 'Cuerpo';

  @override
  String get catNature => 'Naturaleza';

  @override
  String get catScience => 'Ciencia';

  @override
  String get catGeography => 'Geografía';

  @override
  String get sceneFriends => 'Con amigos';

  @override
  String get sceneKids => 'Con niños';

  @override
  String get sceneWork => 'En el trabajo';

  @override
  String get sceneFamily => 'En familia';

  @override
  String get sceneLearning => 'Para aprender';

  @override
  String get filterReset => 'Restablecer';

  @override
  String get today => 'Dato de hoy';

  @override
  String get past => 'Datos anteriores';

  @override
  String get kidsNext => 'Siguiente';

  @override
  String get kidsListen => 'Escuchar';

  @override
  String get emptyFeed => 'Ahora no hay datos para mostrar';

  @override
  String get lockedFeedNote =>
      'Los datos anteriores están disponibles con Premium';

  @override
  String get savedTitle => 'Guardados';

  @override
  String get savedEmpty =>
      'Aún no has guardado nada. Toca el marcador en un dato para guardarlo aquí.';

  @override
  String savedLimit(int count) {
    return 'El plan gratuito permite guardar hasta $count datos';
  }

  @override
  String get save => 'Guardar';

  @override
  String get unsave => 'Guardado';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get ratingHeh => '¡Vaya!';

  @override
  String get ratingUseful => '¡Útil!';

  @override
  String get ratingWow => 'Increíble';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsUiLanguage => 'Idioma de la app';

  @override
  String get settingsContentLanguage => 'Idioma de los datos';

  @override
  String get settingsMode => 'Modo de edad';

  @override
  String get settingsModeNote =>
      'Para cambiar el modo hace falta la verificación de un adulto';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsOtherApps => 'Descubre nuestras otras apps';

  @override
  String get settingsPrivacy =>
      'Esta app no recoge información personal de los niños y no muestra anuncios.';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumBenefit1 => 'Lee hasta 30 días de datos anteriores';

  @override
  String get premiumBenefit2 => 'Guardados ilimitados';

  @override
  String get premiumBenefit3 =>
      'Biblioteca completa de datos pasados y análisis a fondo (próximamente)';

  @override
  String premiumSave(int n) {
    return 'Ahorra $n%';
  }

  @override
  String get premiumKidsFree =>
      'Los datos de Kids y Junior son siempre gratuitos.';

  @override
  String get premiumUnavailable => 'Las compras estarán disponibles pronto';

  @override
  String get premiumOffline =>
      'No se pudieron cargar los planes. Conéctate a internet y vuelve a abrir esta pantalla.';

  @override
  String get gateTitle => 'Para los padres';

  @override
  String get gateDescription =>
      'Este paso es para adultos.\nEscribe el resultado de la suma de abajo.';

  @override
  String get gateHint => 'Escribe la respuesta';

  @override
  String get gateWrong => 'Esa no es la respuesta correcta';

  @override
  String get gateOk => 'Siguiente';

  @override
  String get gateCancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get catBugs => 'Insectos';

  @override
  String get catVehicles => 'Vehículos';

  @override
  String get catFood => 'Comida';

  @override
  String get viewAs => 'Nivel de lectura';

  @override
  String get viewOwn => 'Estándar';

  @override
  String get viewJunior => 'Para escolares';

  @override
  String get viewKids => 'Para los más pequeños';

  @override
  String get explainToKids => 'Explicarlo a un niño';

  @override
  String get bilingualOn => 'Mostrar ambos idiomas';

  @override
  String get bilingualOff => 'Mostrar un idioma';

  @override
  String get knewIt => 'Ya lo sabía';

  @override
  String get learnedIt => '¡He aprendido algo!';

  @override
  String streakDays(int count) {
    return 'Racha de $count días';
  }

  @override
  String get streakFreeze => 'Día de descanso listo';

  @override
  String get streakStart => 'Lee el dato de hoy para empezar una racha';

  @override
  String get statsTitle => 'Tus datos';

  @override
  String statsKnowRate(int percent, int knew, int total) {
    return 'Datos que ya sabías: $percent% ($knew/$total)';
  }

  @override
  String get statsEmpty =>
      'Pulsa «Ya lo sabía» o «¡He aprendido algo!» para ver aquí tus estadísticas';

  @override
  String get quizButton => 'Quiz';

  @override
  String get quizTitle => '¿Verdadero o falso?';

  @override
  String get quizTrue => 'Verdadero';

  @override
  String get quizFalse => 'Falso';

  @override
  String get quizCorrect => '¡Correcto!';

  @override
  String get quizWrong => '¡Casi!';

  @override
  String get quizNext => 'Siguiente';

  @override
  String get notifyTitle => 'Recordatorio diario';

  @override
  String get notifySubtitle =>
      'Recibe el dato de hoy a la hora que elijas. Funciona solo en tu dispositivo.';

  @override
  String get notifyJuniorNote =>
      'Debe configurarlo un adulto. Funciona solo en el dispositivo y no envía datos.';

  @override
  String get notifyTime => 'Hora del aviso';

  @override
  String get notifyDenied =>
      'Las notificaciones no están permitidas. Actívalas en los ajustes del dispositivo.';

  @override
  String get birthYearHint => 'Año de nacimiento';

  @override
  String get filterButton => 'Filtrar';

  @override
  String filterButtonActive(int count) {
    return 'Filtrar ($count)';
  }

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get searchHint => 'Buscar datos (japonés / inglés)';

  @override
  String get searchClear => 'Borrar';

  @override
  String resultsCount(int count) {
    return '$count datos';
  }

  @override
  String get noResults =>
      'No se ha encontrado nada. Prueba con otras palabras o filtros';

  @override
  String get filterStatus => 'Estado';

  @override
  String get statusSaved => 'Guardado';

  @override
  String get statusKnew => 'Ya lo sabía';

  @override
  String get statusLearned => 'Nuevo para mí';

  @override
  String get statusUnrated => 'Sin valorar';

  @override
  String get filterCategoryHeader => 'Tema';

  @override
  String get filterSceneHeader => 'Ocasión';

  @override
  String get libraryLocked => 'Requiere Premium';

  @override
  String get libraryOpen => 'Biblioteca';

  @override
  String get interestsSection => 'Tus intereses';

  @override
  String get interestsEdit => 'Editar';

  @override
  String get interestsEmptyTitle =>
      'Añade tus intereses para ver aquí recomendaciones';

  @override
  String get interestsRegister => 'Añadir intereses';

  @override
  String get interestsNoMatch =>
      'Ahora no hay datos que encajen con tus intereses';

  @override
  String get interestsScreenTitle => 'Intereses';

  @override
  String get interestsCategories => 'Temas';

  @override
  String get interestsScenes => 'Ocasiones';

  @override
  String get interestsKeywords => 'Palabras clave';

  @override
  String get interestsKeywordHint => 'p. ej.: espacio, nutria, dinero';

  @override
  String get interestsAdd => 'Añadir';

  @override
  String interestsMax(int count) {
    return 'Hasta $count palabras clave';
  }

  @override
  String get interestsNote =>
      'Tus intereses se quedan en este dispositivo y no se envían a ninguna parte.';

  @override
  String get settingsInterests => 'Intereses';

  @override
  String get timingSection => 'Ahora mismo';

  @override
  String get reasonDate => 'Un día especial';

  @override
  String reasonSeason(String season) {
    return 'Perfecto para $season';
  }

  @override
  String get reasonNight => 'Ideal para esta noche';

  @override
  String get reasonMorning => 'Ideal para la mañana';

  @override
  String get reasonEvening => 'Ideal para la tarde';

  @override
  String get reasonWeekend => 'Para el fin de semana';

  @override
  String get seasonSpring => 'la primavera';

  @override
  String get seasonSummer => 'el verano';

  @override
  String get seasonAutumn => 'el otoño';

  @override
  String get seasonWinter => 'el invierno';

  @override
  String get settingsRegion => 'País / región';

  @override
  String get regionAuto => 'Automático (ajuste del dispositivo)';

  @override
  String get regionAll => 'Todos los países';

  @override
  String get regionNote =>
      'Los datos específicos de un país solo se muestran para el país seleccionado.';

  @override
  String get settingsSeason => 'Recomendaciones de temporada';

  @override
  String get seasonAuto => 'Auto';

  @override
  String get seasonNorth => 'Norte';

  @override
  String get seasonSouth => 'Sur';

  @override
  String get seasonOff => 'Off';

  @override
  String get seasonNote =>
      'Se calcula a partir de tu zona horaria (no se usa la ubicación).';

  @override
  String get relatedSection => 'Datos relacionados';

  @override
  String get whyButton => '¿Por qué?';

  @override
  String whyCheer(int count) {
    return '¡Has preguntado «¿por qué?» $count veces! ¡Genial!';
  }

  @override
  String get mythsTitle => '¿Verdadero o falso?';

  @override
  String mythAnswerIs(String verdict) {
    return 'La respuesta: $verdict';
  }

  @override
  String get mythRead => 'Leer más';

  @override
  String mythProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String mythResult(int correct, int total) {
    return '¡$correct de $total correctas!';
  }

  @override
  String get mythAgain => 'Jugar de nuevo';

  @override
  String get mythNone => 'Ahora no hay preguntas para jugar';

  @override
  String get mythNext => 'Siguiente';

  @override
  String get mythFinish => 'Ver resultados';

  @override
  String get todayTitle => 'Un día como hoy';

  @override
  String get todayNone => 'Hoy no es un día especial';

  @override
  String get todayUpcoming => 'Próximamente';

  @override
  String todayBanner(String title) {
    return 'Hoy: $title';
  }

  @override
  String get todayCountry => 'Celebración local';

  @override
  String get todayHome => 'Un día como hoy';

  @override
  String dateMonthDay(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get listenInEnglish => 'Escuchar en inglés';

  @override
  String get listenInJapanese => 'Escuchar en japonés';

  @override
  String get vocabEnglishTitle => 'Palabras en inglés';

  @override
  String get vocabJapaneseTitle => 'Palabras en japonés';

  @override
  String get vocabTapToHear => 'Toca una palabra para escucharla';

  @override
  String get listenTitle => 'Modo escucha';

  @override
  String get listenPlay => 'Reproducir';

  @override
  String get listenPause => 'Pausa';

  @override
  String get listenNext => 'Siguiente';

  @override
  String get listenPrev => 'Anterior';

  @override
  String get listenSpeedLabel => 'Velocidad';

  @override
  String get listenNormal => 'Normal';

  @override
  String get listenFast => 'Rápida';

  @override
  String get listenFinished =>
      'Eso es todo. Pulsa reproducir para escuchar de nuevo';

  @override
  String get listenNote =>
      'Mantén la app abierta mientras escuchas (en el trayecto, cocinando...).';

  @override
  String get listenEmpty => 'Ahora no hay datos para escuchar';

  @override
  String get listenOpen => 'Modo escucha';

  @override
  String get projectsTitle => 'Ideas de experimentos científicos';

  @override
  String projectMinutes(int minutes) {
    return 'Unos $minutes min';
  }

  @override
  String get projectNeedsAdult => 'Con un adulto';

  @override
  String get projectDifficulty => 'Dificultad';

  @override
  String get projectMaterials => 'Qué necesitas';

  @override
  String get projectSteps => 'Pasos';

  @override
  String get projectObserve => 'En qué fijarse';

  @override
  String get projectSafety => 'Seguridad';

  @override
  String get projectFromFact => 'Probarlo como experimento';

  @override
  String get projectsEmpty => 'Ahora no hay experimentos para mostrar';

  @override
  String get projectsSummer => 'Genial para las vacaciones de verano';

  @override
  String get quickLinks => 'Más';

  @override
  String get projectsIntro =>
      'De un dato curioso a un experimento que puedes hacer en casa.';

  @override
  String get premiumActive => 'Tienes Premium';

  @override
  String get premiumMonthly => 'Mensual';

  @override
  String get premiumAnnual => 'Anual';

  @override
  String get premiumTrial => 'Prueba gratuita disponible';

  @override
  String get premiumBuy => 'Empezar con este plan';

  @override
  String get premiumRestore => 'Restaurar compras';

  @override
  String get premiumLegal =>
      'El pago se carga en tu cuenta de la tienda. Los planes se renuevan automáticamente y puedes cancelarlos cuando quieras en los ajustes de la tienda. Los planes con prueba gratuita empiezan a cobrarse automáticamente al terminar la prueba.';

  @override
  String get premiumPurchased => '¡Gracias por tu compra!';

  @override
  String get premiumCancelled => 'Compra cancelada';

  @override
  String get premiumFailed =>
      'No se pudo completar la compra. Inténtalo de nuevo más tarde.';

  @override
  String get premiumRestored => 'Compras restauradas';

  @override
  String get premiumNothingToRestore =>
      'No se encontraron compras que restaurar';

  @override
  String get privacyTitle => 'Privacidad y acerca de';

  @override
  String get privacyDataHeading => 'Cómo tratamos tus datos';

  @override
  String get privacyPointLocal =>
      'Tus ajustes, datos guardados y registros se quedan solo en este dispositivo.';

  @override
  String get privacyPointBirthYear =>
      'Tu año de nacimiento solo se usa para elegir un modo de edad y nunca se guarda.';

  @override
  String get privacyPointNoAds => 'No hay anuncios ni analíticas de uso.';

  @override
  String get privacyPointChildren =>
      'Los modos Kids y Junior no usan conexión de red ni SDK de compras.';

  @override
  String get privacyPointTeenAdult =>
      'Los modos Teen y Adult pueden conectarse para mostrar recomendaciones de apps (se puede desactivar en Ajustes) y comprobar tu estado Premium. Los datos de pago nunca llegan a la app. Solo si activas las «estadísticas mundiales» se envían el ID del dato, el país y la fecha, sin nombre ni cuenta.';

  @override
  String privacyContact(String email) {
    return 'Contacto: $email';
  }

  @override
  String get privacyLicenses => 'Licencias de código abierto';

  @override
  String privacyVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get privacyDeleteButton => 'Borrar los datos de este dispositivo';

  @override
  String get privacyDeleteTitle => '¿Borrar tus datos?';

  @override
  String get privacyDeleteBody =>
      'Se borrarán todos los ajustes, datos guardados, registros y notificaciones programadas, y la app volverá a la pantalla inicial. No se puede deshacer. El Premium que hayas comprado se mantiene (restáuralo desde la tienda).';

  @override
  String get privacyDeleteConfirm => 'Borrar';

  @override
  String get privacyDeleteCancel => 'Cancelar';

  @override
  String get privacyDeleted => 'Datos borrados';

  @override
  String get shareImage => 'Compartir como imagen';

  @override
  String get sourcesSection => 'Fuentes';

  @override
  String get battleTitle => 'Duelo de quiz';

  @override
  String get battlePlayers => '¿Cuántos jugadores?';

  @override
  String get battleSolo => 'Solo';

  @override
  String battlePlayerCount(int n) {
    return '$n jugadores';
  }

  @override
  String battlePlayerDefault(int n) {
    return 'Jugador $n';
  }

  @override
  String get battleRounds => '¿Cuántas preguntas?';

  @override
  String battleRoundCount(int n) {
    return '$n preguntas';
  }

  @override
  String get battleHandHint => 'Pasad el dispositivo y jugad por turnos.';

  @override
  String get battleStart => 'Empezar';

  @override
  String get battleNoQuestions => 'No hay preguntas de quiz disponibles.';

  @override
  String battleRoundOf(int n, int total) {
    return 'Pregunta $n de $total';
  }

  @override
  String battleTurnOf(String name) {
    return 'Turno de $name';
  }

  @override
  String get battleSeeResult => 'Ver resultados';

  @override
  String get battleFinished => '¡Terminado!';

  @override
  String battleSoloScore(int score, int total) {
    return '¡$score de $total correctas!';
  }

  @override
  String get battleDraw => '¡Empate!';

  @override
  String battleWinner(String name) {
    return '¡$name gana!';
  }

  @override
  String battleRank(int n) {
    return 'N.º $n';
  }

  @override
  String get battleAgain => 'Jugar de nuevo';

  @override
  String get battleChangeSettings => 'Cambiar ajustes';

  @override
  String get battleExit => 'Salir';

  @override
  String get battleKind => 'Tipo de quiz';

  @override
  String get battleKindAll => 'Todos';

  @override
  String get battleKindTrueFalse => 'Verdadero / falso';

  @override
  String get battleKindChoice => 'Opción múltiple';

  @override
  String get battleGenre => 'Tema';

  @override
  String get battleGenreAll => 'Todos';

  @override
  String get battleTimeLimit => 'Límite de tiempo';

  @override
  String get battleTimeOff => 'Ninguno';

  @override
  String battleSeconds(int n) {
    return '$n s';
  }

  @override
  String battleSecondsLeft(int n) {
    return 'Quedan $n s';
  }

  @override
  String get battleTimeHint =>
      'Responder más rápido da puntos extra (sirven para desempatar).';

  @override
  String battleCorrectIs(String answer) {
    return 'La respuesta: $answer';
  }

  @override
  String battlePoints(int n) {
    return '$n pts';
  }

  @override
  String get reviewTitle => 'Repaso';

  @override
  String get reviewNone =>
      'Hoy no hay nada que repasar. Los datos que marques con «¡He aprendido algo!» aparecerán desde mañana.';

  @override
  String get reviewDoneNote => 'Vuelve mañana para repasar más.';

  @override
  String get reviewChip => 'Repaso';

  @override
  String reviewChipCount(int n) {
    return 'Repaso $n';
  }

  @override
  String get dailyTitle => 'Reto diario';

  @override
  String get dailyChip => 'Reto';

  @override
  String dailyStreak(int n) {
    return 'Racha de $n días de retos';
  }

  @override
  String get dailyComeBack => '¡Vuelve mañana para un reto nuevo!';

  @override
  String get dailyShare => 'Compartir resultado';

  @override
  String get badgesTitle => 'Insignias';

  @override
  String get badgesChip => 'Insignias';

  @override
  String badgesCount(int n, int total) {
    return '$n de $total conseguidas';
  }

  @override
  String badgeStreak(int n) {
    return 'Racha de $n días';
  }

  @override
  String badgeReadDays(int n) {
    return 'Leído durante $n días';
  }

  @override
  String badgeLearned(int n) {
    return '$n datos aprendidos';
  }

  @override
  String badgeQuiz(int n) {
    return '$n respuestas de quiz correctas';
  }

  @override
  String badgeDaily(int n) {
    return '$n retos diarios';
  }

  @override
  String get badgePerfect => 'Reto diario perfecto';

  @override
  String get reportTitle => 'Informe de aprendizaje';

  @override
  String get reportNote =>
      'Este informe se crea solo con los registros guardados en este dispositivo. No se envía nada a ninguna parte.';

  @override
  String get reportLearned => 'Datos marcados como «he aprendido algo»';

  @override
  String get reportKnew => 'Datos marcados como «ya lo sabía»';

  @override
  String get reportQuiz => 'Respuestas de quiz correctas';

  @override
  String get reportNoQuiz => 'Todavía ninguna';

  @override
  String get reportReviewPending => 'Pendientes de repaso';

  @override
  String get reportFavorite => 'Temas favoritos';

  @override
  String get reportEmpty => 'Todavía no hay registros.';

  @override
  String get reportRecent => 'Aprendido recientemente';

  @override
  String get reportOpen => 'Informe de aprendizaje (para padres)';

  @override
  String get mascotTitle => 'Compañero';

  @override
  String mascotNext(int n, String name) {
    return 'Faltan $n para ser «$name»';
  }

  @override
  String get mascotMax => '¡Totalmente crecido!';

  @override
  String get mascotHint =>
      'Abre un dato: +1. Marca «¡He aprendido algo!»: +2. Tu compañero crece contigo.';

  @override
  String mascotPoints(int n) {
    return '$n puntos';
  }

  @override
  String get mascotLocked => '???';

  @override
  String get mascotName_egg => 'Huevo';

  @override
  String get mascotSay_egg => '…esperando un dato curioso.';

  @override
  String get mascotName_chick => 'Pollito';

  @override
  String get mascotSay_chick => '¡Pío! ¡Los datos son divertidos!';

  @override
  String get mascotName_chicklet => 'Búho pequeño';

  @override
  String get mascotSay_chicklet => '¡Qué suavecito! Cuéntame más.';

  @override
  String get mascotName_owl => 'Búho';

  @override
  String get mascotSay_owl => '¡Uuuh! Me estoy volviendo sabio.';

  @override
  String get mascotName_professor => 'Profesor Búho';

  @override
  String get mascotSay_professor => 'Mmm, ya veo. Eres todo un erudito.';

  @override
  String get mascotName_king => 'Rey Búho';

  @override
  String get mascotSay_king => '¡Uuuh-uuuh! ¡El rey de los datos curiosos!';

  @override
  String celebrateStage(String name) {
    return '¡Tu compañero ahora es $name!';
  }

  @override
  String get celebrateBadge => '¡Nueva insignia!';

  @override
  String get flipHint => 'Toca para girar';

  @override
  String get flipDetail => 'Leer más';

  @override
  String get zukanTitle => 'Colección de datos';

  @override
  String get zukanChip => 'Colección';

  @override
  String zukanFound(int n, int total) {
    return '$n de $total encontrados';
  }

  @override
  String get zukanAll => 'Todos';

  @override
  String get zukanHint => 'Cada dato que veas completa tu colección.';

  @override
  String get zukanLocked => '?';

  @override
  String get capsuleTitle => 'Cápsula de datos';

  @override
  String get capsuleChip => 'Cápsula';

  @override
  String get capsuleOpen => '¡Ábrela!';

  @override
  String get capsuleHint => 'Cada día sale un dato misterioso.';

  @override
  String get capsuleDone => '¡Vuelve mañana!';

  @override
  String get capsuleNew => '¡Nuevo!';

  @override
  String get capsuleToZukan => 'Ver colección';

  @override
  String get capsuleEmpty => 'No hay datos disponibles.';

  @override
  String get capsuleRarity1 => 'Común';

  @override
  String get capsuleRarity2 => 'Raro';

  @override
  String get capsuleRarity3 => 'Súper raro';

  @override
  String get swipeTitle => 'Desliza: ¿verdadero o falso?';

  @override
  String get swipeChip => 'Deslizar';

  @override
  String get swipeHint => '→ verdadero     ← falso';

  @override
  String swipeCombo(int n) {
    return '🔥 ¡$n seguidas!';
  }

  @override
  String swipeBestCombo(int n) {
    return 'Mejor racha: $n';
  }

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabPlay => 'Jugar';

  @override
  String get tabCollect => 'Colección';

  @override
  String get tabExplore => 'Explorar';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get hubPlayIntro =>
      'Disfruta de los datos curiosos con quizzes y juegos.';

  @override
  String get hubCollectIntro =>
      'Cuantos más datos veas, más crece tu compañero y más se llena tu colección.';

  @override
  String get hubExploreIntro => 'Busca datos o profundiza en ellos.';

  @override
  String get hubQuizSub => '1-4 jugadores';

  @override
  String get hubSwipeSub => 'Verdadero o falso';

  @override
  String get hubDailySub => '3 preguntas al día';

  @override
  String get hubReviewSub => 'Para no olvidar';

  @override
  String get hubMythsSub => 'Ideas equivocadas comunes';

  @override
  String get hubLibrarySub => 'Búsqueda y temas';

  @override
  String get hubListenSub => 'Suena con la pantalla apagada';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageKo => '한국어';

  @override
  String get languageEs => 'Español';

  @override
  String get wordTitle => 'Palabra explicada';

  @override
  String get wordSimple => 'En pocas palabras';

  @override
  String get wordDetail => 'Con más detalle';

  @override
  String get wordFacts => 'Datos que usan esta palabra';

  @override
  String get wordHint => 'Toca una palabra subrayada para ver qué significa.';

  @override
  String get wordNotFound => 'No se encontró la explicación.';

  @override
  String get wordsTitle => 'Libro de palabras';

  @override
  String wordsFound(int n, int total) {
    return '$n de $total palabras';
  }

  @override
  String get wordOfDay => 'Palabra del día';

  @override
  String get wordQuizTitle => 'Quiz de palabras';

  @override
  String wordQuizQuestion(String term) {
    return '¿Qué significa «$term»?';
  }

  @override
  String get wordsHint => 'Las palabras que consultes se añaden aquí.';

  @override
  String get mapTitle => 'Mapa de conexiones';

  @override
  String mapLinkCount(int n) {
    return '$n datos conectados';
  }

  @override
  String get mapNoLinks => 'Todavía no hay datos conectados';

  @override
  String get mapOpen => 'Ver conexiones';

  @override
  String get voiceQuizTitle => 'Quiz de escucha';

  @override
  String get voiceReplay => 'Escuchar otra vez';

  @override
  String get voiceQuizSub => 'Escucha y responde';

  @override
  String get leagueTitle => 'Liga familiar';

  @override
  String get leagueNote =>
      'Se suman cada semana las puntuaciones de los duelos jugados en este dispositivo. No se envía nada a ninguna parte.';

  @override
  String get leagueThisWeek => 'Esta semana';

  @override
  String leagueLastWinner(String name) {
    return 'Campeón de la semana pasada: $name';
  }

  @override
  String get leagueEmpty =>
      'Todavía no hay registros. Juega un duelo con dos o más jugadores y aparecerá aquí.';

  @override
  String leagueGames(int n, int wins) {
    return '$n partidas, $wins victorias';
  }

  @override
  String get leaguePlay => 'Jugar un duelo';

  @override
  String get leagueClear => 'Borrar los registros de esta semana';

  @override
  String get leagueClearTitle => '¿Borrar los registros de esta semana?';

  @override
  String get leagueClearBody =>
      'Se borrarán las puntuaciones de esta semana. El campeón de la semana pasada se mantiene.';

  @override
  String get leagueRecord => 'Registrar en la liga familiar';

  @override
  String get leagueSub => 'Un reto semanal';

  @override
  String get recapTitle => 'Resumen semanal';

  @override
  String get recapNote =>
      'Los últimos 7 días, comparados con los 7 anteriores.';

  @override
  String get recapSeen => 'Datos vistos';

  @override
  String get recapLearned => 'Cosas nuevas aprendidas';

  @override
  String get recapQuiz => 'Respuestas de quiz correctas';

  @override
  String get recapActiveDays => 'Días activos';

  @override
  String get recapMsgNone =>
      'Una semana tranquila. ¡Lee un dato para retomar el ritmo!';

  @override
  String get recapMsgSome => '¡Buen ritmo! Se va sumando poco a poco.';

  @override
  String get recapMsgGreat => '¡Increíble! ¡Casi todos los días!';

  @override
  String get recapChip => 'Resumen';

  @override
  String get recapBanner => 'Tu resumen semanal está listo';

  @override
  String get stampsTitle => 'Álbum de sellos de temporada';

  @override
  String get stampsChip => 'Sellos';

  @override
  String stampsHint(int n) {
    return 'Lee un dato que encaje con la temporada actual para ganar un sello. Con $n, tu compañero se pone el atuendo de esa estación.';
  }

  @override
  String get stampsSpring => 'Primavera';

  @override
  String get stampsSummer => 'Verano';

  @override
  String get stampsAutumn => 'Otoño';

  @override
  String get stampsWinter => 'Invierno';

  @override
  String get stampsNow => 'Ahora';

  @override
  String get stampsOutfit => '¡Atuendo desbloqueado!';

  @override
  String get celebrateOutfit => '¡Atuendo de temporada desbloqueado!';
}
