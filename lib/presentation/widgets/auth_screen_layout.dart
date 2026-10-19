import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/locale_bloc.dart';
import '../blocs/locale_event.dart';

class AuthScreenLayout extends StatelessWidget {
  const AuthScreenLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.imageHeightFraction = 0.5,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final double imageHeightFraction;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * imageHeightFraction;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: imageHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/login_bg.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                          PositionedDirectional(
                            top: MediaQuery.paddingOf(context).top + 8,
                            end: 16,
                            child: Material(
                              color: Colors.black54,
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: AppLocalizations.of(context)
                                    .switchLanguage,
                                icon: const Icon(
                                  Icons.language,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  final bloc = context.read<LocaleBloc>();
                                  bloc.add(
                                    ChangeLocale(
                                      Locale(
                                        bloc.state.languageCode == 'ar'
                                            ? 'en'
                                            : 'ar',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - imageHeight,
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                      color: AppTheme.green,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: AppTheme.sectionFont,
                                  fontSize: 30,
                                  height: 1.07,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 28),
                              child,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
