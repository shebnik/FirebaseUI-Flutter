// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart'
    hide OAuthProviderButtonBase;
import 'package:flutter/material.dart' hide Title;

import '../widgets/internal/title.dart';

typedef AuthViewContentBuilder = Widget Function(
  BuildContext context,
  AuthAction action,
);

/// {@template ui.auth.views.login_view}
/// A view that could be used to build a custom [SignInScreen] or
/// [RegisterScreen].
/// {@endtemplate}
class LoginView extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction action;

  /// Indicates whether icon-only or icon and text OAuth buttons should be used.
  /// Icon-only buttons are placed in a row.
  final OAuthButtonVariant? oauthButtonVariant;
  final bool? showTitle;
  final String? email;

  /// Whether the "Login/Register" link should be displayed. The link changes
  /// the type of the [AuthAction] from [AuthAction.signIn]
  /// and [AuthAction.signUp] and vice versa.
  final bool? showAuthActionSwitch;

  /// {@template ui.auth.views.login_view.footer_builder}
  /// A returned widget would be placed down the authentication related widgets.
  /// {@endtemplate}
  final AuthViewContentBuilder? footerBuilder;

  /// {@template ui.auth.views.login_view.subtitle_builder}
  /// A returned widget would be placed up the authentication related widgets.
  /// {@endtemplate}
  final AuthViewContentBuilder? subtitleBuilder;

  final List<AuthProvider> providers;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// {@macro ui.auth.widgets.email_from.showPasswordVisibilityToggle}
  final bool showPasswordVisibilityToggle;

  /// Whether the confirm password field should be displayed.
  /// Defaults to `true`.
  /// If set to `false`, the confirm password field will not be displayed.
  final bool showConfirmPassword;

  /// A widget that would be placed above the authentication related widgets.
  final Widget? logo;

  /// A callback that would be called when the "Terms of Service" link is pressed.
  /// If not provided, the widget will not be displayed.
  final void Function()? onTermsPressed;

  /// Whether the name field is required.
  final bool nameRequired;

  /// {@macro ui.auth.views.login_view}
  const LoginView({
    super.key,
    required this.action,
    required this.providers,
    this.oauthButtonVariant = OAuthButtonVariant.icon_and_text,
    this.auth,
    this.showTitle = true,
    this.email,
    this.showAuthActionSwitch,
    this.footerBuilder,
    this.subtitleBuilder,
    this.actionButtonLabelOverride,
    this.showPasswordVisibilityToggle = false,
    this.showConfirmPassword = true,
    this.logo,
    this.onTermsPressed,
    this.nameRequired = false,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late AuthAction _action = widget.action;
  bool get _showTitle => widget.showTitle ?? true;
  bool get _showAuthActionSwitch => widget.showAuthActionSwitch ?? true;
  bool _buttonsBuilt = false;

  void setAction(AuthAction action) {
    setState(() {
      _action = action;
    });
  }

  Widget _buildOAuthButtons(TargetPlatform platform) {
    final oauthProviders = widget.providers
        .whereType<OAuthProvider>()
        .where((element) => element.supportsPlatform(platform));

    _buttonsBuilt = true;

    final oauthButtonsList = oauthProviders.map((provider) {
      return OAuthProviderButton(
        provider: provider,
        auth: widget.auth,
        action: _action,
        variant: widget.oauthButtonVariant,
      );
    }).toList();

    if (widget.oauthButtonVariant == OAuthButtonVariant.icon_and_text) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: oauthButtonsList,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: oauthButtonsList,
      );
    }
  }

  void _handleDifferentAuthAction(BuildContext context) {
    if (_action == AuthAction.signIn) {
      setState(() {
        _action = AuthAction.signUp;
      });
    } else {
      setState(() {
        _action = AuthAction.signIn;
      });
    }
  }

  List<Widget> _buildHeader(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    late String title;

    if (_action == AuthAction.signIn) {
      title = l.signInText;
    } else if (_action == AuthAction.signUp) {
      title = l.registerText;
    }

    return [
      Title(text: title),
      const SizedBox(height: 16),
      if (widget.subtitleBuilder != null)
        widget.subtitleBuilder!(
          context,
          _action,
        ),
    ];
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    if (oldWidget.action != widget.action) {
      _action = widget.action;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final platform = Theme.of(context).platform;
    _buttonsBuilt = false;

    return IntrinsicHeight(
      child: Column(
        children: [
          if (widget.logo != null) ...[
            widget.logo!,
            const SizedBox(height: 6),
          ],
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showTitle) ..._buildHeader(context),
                  for (var provider in widget.providers)
                    if (provider.supportsPlatform(platform))
                      if (provider is EmailAuthProvider) ...[
                        const SizedBox(height: 8),
                        EmailForm(
                          key: ValueKey(_action),
                          auth: widget.auth,
                          action: _action,
                          provider: provider,
                          email: widget.email,
                          actionButtonLabelOverride:
                              widget.actionButtonLabelOverride,
                          showPasswordVisibilityToggle:
                              widget.showPasswordVisibilityToggle,
                          showConfirmPassword: widget.showConfirmPassword,
                          onTermsPressed: widget.onTermsPressed,
                          nameRequired: widget.nameRequired,
                          logo: widget.logo,
                        ),
                        if (_showAuthActionSwitch) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            child: Text(
                              _action == AuthAction.signIn
                                  ? l.registerText
                                  : l.signInText,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            onPressed: () =>
                                _handleDifferentAuthAction(context),
                          ),
                        ],
                      ] else if (provider is PhoneAuthProvider) ...[
                        const SizedBox(height: 8),
                        PhoneVerificationButton(
                          label: l.signInWithPhoneButtonText,
                          action: _action,
                          auth: widget.auth,
                        ),
                        const SizedBox(height: 8),
                      ] else if (provider is EmailLinkAuthProvider) ...[
                        const SizedBox(height: 8),
                        EmailLinkSignInButton(
                          auth: widget.auth,
                          provider: provider,
                        ),
                      ] else if (provider is OAuthProvider && !_buttonsBuilt)
                        _buildOAuthButtons(platform),
                  if (widget.footerBuilder != null)
                    widget.footerBuilder!(
                      context,
                      _action,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
