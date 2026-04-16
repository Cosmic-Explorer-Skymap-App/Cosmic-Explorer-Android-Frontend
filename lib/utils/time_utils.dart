import '../l10n/generated/app_localizations.dart';

/// Returns a localized relative time string for [dt].
/// Requires an [AppLocalizations] instance obtained from BuildContext.
String formatTimeAgo(DateTime dt, AppLocalizations l10n) {
  final diff = DateTime.now().toUtc().difference(dt.toUtc());
  if (diff.inSeconds < 60) return l10n.timeJustNow;
  if (diff.inMinutes < 60) return '${diff.inMinutes}${l10n.timeMinuteSuffix}';
  if (diff.inHours < 24) return '${diff.inHours}${l10n.timeHourSuffix}';
  if (diff.inDays < 7) return '${diff.inDays}${l10n.timeDaySuffix}';
  return '${dt.day}.${dt.month}.${dt.year}';
}
