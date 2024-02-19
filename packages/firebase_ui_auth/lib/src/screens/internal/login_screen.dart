// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;

import 'responsive_page.dart';

class LoginScreen extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;
  final AuthAction action;
  final List<AuthProvider> providers;

  /// {@macro ui.auth.screens.responsive_page.header_builder}
  final HeaderBuilder? headerBuilder;

  /// {@macro ui.auth.screens.responsive_page.header_max_extent}
  final double? headerMaxExtent;

  /// Indicates whether icon-only or icon and text OAuth buttons should be used.
  /// Icon-only buttons are placed in a row.
  final OAuthButtonVariant? oauthButtonVariant;

  /// {@macro ui.auth.screens.responsive_page.side_builder}
  final SideBuilder? sideBuilder;

  /// {@macro ui.auth.screens.responsive_page.desktop_layout_direction}
  final TextDirection? desktopLayoutDirection;
  final String? email;

  /// Whether the "Login/Register" link should be displayed. The link changes
  /// the type of the [AuthAction] from [AuthAction.signIn]
  /// and [AuthAction.signUp] and vice versa.
  final bool? showAuthActionSwitch;

  /// See [Scaffold.resizeToAvoidBottomInset]
  final bool? resizeToAvoidBottomInset;

  /// A returned widget would be placed up the authentication related widgets.
  final AuthViewContentBuilder? subtitleBuilder;

  /// A returned widget would be placed down the authentication related widgets.
  final AuthViewContentBuilder? footerBuilder;
  final Key? loginViewKey;

  /// {@macro ui.auth.screens.responsive_page.breakpoint}
  final double breakpoint;
  final Set<FirebaseUIStyle>? styles;

  /// {@macro ui.auth.widgets.email_form.showPasswordVisibilityToggle}
  final bool showPasswordVisibilityToggle;

  /// {@macro ui.auth.screens.responsive_page.max_width}
  final double? maxWidth;

  /// Whether the confirm password field should be displayed.
  /// Defaults to `true`.
  /// If set to `false`, the confirm password field will not be displayed.
  final bool showConfirmPassword;

  /// A callback that is called when the "Terms of Service" link is pressed.
  /// If not provided, the widget will not be displayed.
  /// If provided, the widget will be displayed below the password field.
  final void Function()? onTermsPressed;

  /// A widget that would be placed above the authentication related widgets.
  /// If not provided, the widget will not be displayed.
  final Widget? logo;  
  
  /// Whether the name field is required.
  final bool nameRequired;

  const LoginScreen({
    super.key,
    required this.action,
    required this.providers,
    this.auth,
    this.oauthButtonVariant,
    this.headerBuilder,
    this.headerMaxExtent = defaultHeaderImageHeight,
    this.sideBuilder,
    this.desktopLayoutDirection = TextDirection.ltr,
    this.email,
    this.showAuthActionSwitch,
    this.resizeToAvoidBottomInset = false,
    this.subtitleBuilder,
    this.footerBuilder,
    this.loginViewKey,
    this.breakpoint = 800,
    this.styles,
    this.showPasswordVisibilityToggle = false,
    this.maxWidth,
    this.showConfirmPassword = true,
    this.onTermsPressed,
    this.logo,
    this.nameRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final loginContent = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LoginView(
          key: loginViewKey,
          action: action,
          auth: auth,
          providers: providers,
          oauthButtonVariant: oauthButtonVariant,
          email: email,
          showAuthActionSwitch: showAuthActionSwitch,
          subtitleBuilder: subtitleBuilder,
          footerBuilder: footerBuilder,
          showPasswordVisibilityToggle: showPasswordVisibilityToggle,
          showConfirmPassword: showConfirmPassword,
          logo: logo,
          onTermsPressed: onTermsPressed,
          nameRequired: nameRequired,
        ),
      ),
    );

    final body = ResponsivePage(
      breakpoint: breakpoint,
      desktopLayoutDirection: desktopLayoutDirection,
      headerBuilder: headerBuilder,
      headerMaxExtent: headerMaxExtent,
      sideBuilder: sideBuilder,
      maxWidth: maxWidth,
      child: loginContent,
    );

    return FirebaseUITheme(
      styles: styles ?? const {},
      child: UniversalScaffold(
        body: body,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
