import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../state/settings_controller.dart';
import '../widgets/common.dart';

/// Gizlilik politikası ve uygulama bilgileri.
///
/// Apple 5.1.1 ve Play "kullanıcı verisi" politikaları, gizlilik politikasına
/// uygulamanın **içinden** de erişilebilmesini bekler.
const privacyPolicyUrl = 'https://sites.google.com/view/altin-defterim';

const _appVersion = '1.1.0 (2)';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    // Ayar değiştiğinde (dil, tema) ekran kendini yenilesin.
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(context.l10n.text('about')),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.chevron_back,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 40),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.softGold(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  CupertinoIcons.square_stack_3d_up_fill,
                  size: 46,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Altın Defterim',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.text('appTagline'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$_appVersion · C&A Digital Ventures',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 28),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Row(
                    icon: CupertinoIcons.lock_shield,
                    label: context.l10n.text('privacyPolicy'),
                    onTap: () => openPrivacyPolicy(context),
                  ),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 52),
                    color: AppColors.border(context),
                  ),
                  _LanguageRow(settings: settings),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 52),
                    color: AppColors.border(context),
                  ),
                  _ThemeRow(settings: settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openPrivacyPolicy(BuildContext context) async {
  HapticFeedback.lightImpact();
  try {
    await launchExternal(privacyPolicyUrl);
  } on Object {
    if (!context.mounted) return;
    await showAppMessage(
      context,
      context.l10n.text('privacyPolicy'),
      '${context.l10n.text('openPrivacyPolicyFailed')}\n$privacyPolicyUrl',
    );
  }
}

/// Tarayıcıda harici bağlantı açar.
///
/// `url_launcher` bağımlılığı eklememek için platform kanalı doğrudan
/// kullanılıyor; tek bir sabit bağlantı açıldığı için bu yeterli.
Future<void> launchExternal(String url) async {
  const channel = MethodChannel('altin_hesaplama/links');
  await channel.invokeMethod<void>('open', {'url': url});
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gold),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoColors.systemGrey3,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final isEnglish = settings.locale.languageCode == 'en';
    void apply(bool value) {
      HapticFeedback.selectionClick();
      settings.setLocale(Locale(value ? 'en' : 'tr'));
    }

    return _ToggleRow(
      icon: CupertinoIcons.globe,
      label: isEnglish ? 'English' : 'Türkçe',
      onTap: () => apply(!isEnglish),
      trailing: _Switch(value: isEnglish, onChanged: apply),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    void toggle() {
      HapticFeedback.selectionClick();
      settings.toggleDarkMode();
    }

    return _ToggleRow(
      icon: settings.isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max,
      label: context.l10n.text(settings.isDark ? 'darkMode' : 'lightMode'),
      onTap: toggle,
      trailing: _Switch(value: settings.isDark, onChanged: (_) => toggle()),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  /// Satırın tamamı dokunulabilir; switch'ten daha geniş bir hedef alanı verir.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gold),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: CupertinoSwitch(value: value, onChanged: onChanged),
    );
  }
}
