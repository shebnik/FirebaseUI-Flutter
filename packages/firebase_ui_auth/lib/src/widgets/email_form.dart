// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_auth/src/widgets/name_input.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../validators.dart';

/// {@template ui.auth.widgets.email_form.forgot_password_action}
/// An action that indicates that password recovery was triggered from the UI.
///
/// Could be used to show a [ForgotPasswordScreen] or trigger a custom
/// logic:
///
/// ```dart
/// SignInScreen(
///   actions: [
///     ForgotPasswordAction((context, email) {
///       Navigator.of(context).push(
///         MaterialPageRoute(
///           builder: (context) => ForgotPasswordScreen(),
///         ),
///       );
///     }),
///   ]
/// );
/// ```
/// {@endtemplate}
class ForgotPasswordAction extends FirebaseUIAction {
  /// A callback that is being called when a password recovery flow was
  /// triggered.
  final void Function(BuildContext context, String? email) callback;

  /// {@macro ui.auth.widgets.email_form.forgot_password_action}
  ForgotPasswordAction(this.callback);
}

typedef EmailFormSubmitCallback = void Function(
  String email,
  String password, {
  String? displayName,
});

/// {@template ui.auth.widgets.email_form.email_form_style}
/// An object that is being used to apply styles to the email form.
///
/// For example:
///
/// ```dart
/// EmailForm(
///   style: EmailFormStyle(
///     signInButtonVariant: ButtonVariant.text,
///   ),
/// );
/// ```
/// {@endtemplate}
class EmailFormStyle extends FirebaseUIStyle {
  /// A [ButtonVariant] that should be used for the sign in button.
  final ButtonVariant signInButtonVariant;

  /// An override of the global [ThemeData.inputDecorationTheme].
  final InputDecorationTheme? inputDecorationTheme;

  /// {@macro ui.auth.widgets.email_form.email_form_style}
  const EmailFormStyle({
    this.signInButtonVariant = ButtonVariant.outlined,
    this.inputDecorationTheme,
  });

  @override
  Widget applyToMaterialTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: inputDecorationTheme,
      ),
      child: child,
    );
  }
}

/// {@template ui.auth.widgets.email_form}
/// An email form widget.
/// {@endtemplate}
class EmailForm extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// An instance of the [EmailAuthProvider] that is being used to authenticate.
  final EmailAuthProvider? provider;

  /// A callback that is being called when the form was submitted.
  final EmailFormSubmitCallback? onSubmit;

  /// An email that should be pre-filled in the form.
  final String? email;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// An object that is being used to apply styling configuration to the email
  /// form.
  ///
  /// Alternatively [FirebaseUITheme] could be used to provide styling
  /// configuration.
  /// ```dart
  /// runApp(
  ///   const FirebaseUITheme(
  ///     styles: {
  ///       EmailFormStyle(signInButtonVariant: ButtonVariant.text),
  ///     },
  ///     child: MaterialApp(
  ///       home: MyScreen(),
  ///     ),
  ///   ),
  /// );
  ///
  /// class MyScreen extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Scaffold(
  ///       appBar: AppBar(
  ///         title: Text('Email sign in'),
  ///       ),
  ///       body: Center(child: EmailForm()),
  ///     );
  ///   }
  /// }
  /// ```
  final EmailFormStyle? style;

  /// {@template ui.auth.widgets.email_from.showPasswordVisibilityToggle}
  /// Whether to show the password visibility toggle button.
  /// {@endtemplate}
  final bool showPasswordVisibilityToggle;

  /// Whether the confirm password field should be displayed.
  /// Defaults to `true`.
  /// If set to `false`, the confirm password field will not be displayed.
  final bool showConfirmPassword;

  /// If provided, the terms will be displayed.
  final void Function()? onTermsPressed;

  /// Whether the name field is required.
  final bool nameRequired;

  /// A widget that would be placed above the authentication related widgets.
  final Widget? logo;

  /// {@macro ui.auth.widgets.email_form}
  const EmailForm({
    super.key,
    this.action,
    this.auth,
    this.provider,
    this.onSubmit,
    this.email,
    this.actionButtonLabelOverride,
    this.style,
    this.showPasswordVisibilityToggle = false,
    this.showConfirmPassword = true,
    this.nameRequired = false,
    this.onTermsPressed,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    final child = _SignInFormContent(
      action: action ?? AuthAction.signIn,
      auth: auth,
      provider: provider,
      email: email,
      onSubmit: onSubmit,
      actionButtonLabelOverride: actionButtonLabelOverride,
      style: style,
      showPasswordVisibilityToggle: showPasswordVisibilityToggle,
      showConfirmPassword: showConfirmPassword,
      nameRequired: nameRequired,
      onTermsPressed: onTermsPressed,
      logo: logo,
    );

    return AuthFlowBuilder<EmailAuthController>(
      auth: auth,
      action: action,
      provider: provider,
      child: child,
    );
  }
}

class _SignInFormContent extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;
  final EmailFormSubmitCallback? onSubmit;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;
  final String? email;
  final EmailAuthProvider? provider;

  final String? actionButtonLabelOverride;
  final bool showPasswordVisibilityToggle;
  final bool showConfirmPassword;
  final bool nameRequired;

  final void Function()? onTermsPressed;
  final Widget? logo;

  final EmailFormStyle? style;

  const _SignInFormContent({
    this.auth,
    this.onSubmit,
    this.action,
    this.email,
    this.provider,
    this.actionButtonLabelOverride,
    this.style,
    this.showPasswordVisibilityToggle = false,
    this.showConfirmPassword = true,
    this.nameRequired = false,
    this.onTermsPressed,
    this.logo,
  });

  @override
  _SignInFormContentState createState() => _SignInFormContentState();
}

class _SignInFormContentState extends State<_SignInFormContent> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  String _chooseButtonLabel() {
    final ctrl = AuthController.ofType<EmailAuthController>(context);
    final l = FirebaseUILocalizations.labelsOf(context);

    switch (ctrl.action) {
      case AuthAction.signIn:
        return widget.actionButtonLabelOverride ?? l.signInActionText;
      case AuthAction.signUp:
        return l.registerActionText;
      case AuthAction.link:
        return l.linkEmailButtonText;
      default:
        throw Exception('Invalid auth action: ${ctrl.action}');
    }
  }

  void _submit([String? password]) {
    FocusManager.instance.primaryFocus?.unfocus();

    final ctrl = AuthController.ofType<EmailAuthController>(context);
    final name = (widget.nameRequired ? nameCtrl.text : null)?.trim();
    final email = (widget.email ?? emailCtrl.text).trim();

    if (formKey.currentState!.validate()) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(
          email,
          passwordCtrl.text,
          displayName: name,
        );
      } else {
        ctrl.setEmailAndPassword(
          email,
          password ?? passwordCtrl.text,
          displayName: name,
        );
      }
    }
  }

  Widget _buildTerms(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    TextStyle? hintStyle;
    late Color registerTextColor;

    if (isCupertino) {
      final theme = CupertinoTheme.of(context);
      registerTextColor = theme.primaryColor;
      hintStyle = theme.textTheme.textStyle.copyWith(fontSize: 12);
    } else {
      final theme = Theme.of(context);
      hintStyle = Theme.of(context).textTheme.bodySmall;
      registerTextColor = theme.colorScheme.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${l.agreeToTermsOfService} ',
              style: hintStyle,
            ),
            TextSpan(
              text: '${l.agreeToTermsOfServiceLinkText}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: registerTextColor,
                    fontWeight: FontWeight.bold,
                  ),
              mouseCursor: SystemMouseCursors.click,
              recognizer: TapGestureRecognizer()
                ..onTap = widget.onTermsPressed ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    const spacer = SizedBox(height: 16);

    final children = [
      if (widget.nameRequired && widget.action == AuthAction.signUp) ...[
        NameInput(
          focusNode: nameFocusNode,
          controller: nameCtrl,
          onSubmitted: (v) {
            formKey.currentState?.validate();
            FocusScope.of(context).requestFocus(emailFocusNode);
          },
        ),
        spacer,
      ],
      if (widget.email == null) ...[
        EmailInput(
          focusNode: emailFocusNode,
          controller: emailCtrl,
          onSubmitted: (v) {
            formKey.currentState?.validate();
            FocusScope.of(context).requestFocus(passwordFocusNode);
          },
        ),
        spacer,
      ],
      PasswordInput(
        focusNode: passwordFocusNode,
        controller: passwordCtrl,
        onSubmit: _submit,
        placeholder: l.passwordInputLabel,
        showVisibilityToggle: widget.showPasswordVisibilityToggle,
      ),
      if (widget.action == AuthAction.signIn) ...[
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ForgotPasswordButton(
            onPressed: () {
              final navAction =
                  FirebaseUIAction.ofType<ForgotPasswordAction>(context);

              if (navAction != null) {
                navAction.callback(context, emailCtrl.text);
              } else {
                showForgotPasswordScreen(
                  context: context,
                  email: emailCtrl.text,
                  auth: widget.auth,
                  logo: widget.logo,
                );
              }
            },
          ),
        ),
      ],
      if (widget.showConfirmPassword &&
          (widget.action == AuthAction.signUp ||
              widget.action == AuthAction.link)) ...[
        const SizedBox(height: 8),
        PasswordInput(
          autofillHints: const [AutofillHints.newPassword],
          focusNode: confirmPasswordFocusNode,
          controller: confirmPasswordCtrl,
          onSubmit: _submit,
          validator: Validator.validateAll([
            NotEmpty(l.confirmPasswordIsRequiredErrorText),
            ConfirmPasswordValidator(
              passwordCtrl,
              l.confirmPasswordDoesNotMatchErrorText,
            )
          ]),
          placeholder: l.confirmPasswordInputLabel,
          showVisibilityToggle: widget.showPasswordVisibilityToggle,
        ),
        const SizedBox(height: 8),
      ],
      if (widget.onTermsPressed != null &&
          widget.action == AuthAction.signUp) ...[
        const SizedBox(height: 35),
        _buildTerms(context),
      ],
      const SizedBox(height: 8),
      Builder(
        builder: (context) {
          final state = AuthState.of(context);
          final style = widget.style ??
              FirebaseUIStyle.ofType<EmailFormStyle>(
                context,
                const EmailFormStyle(),
              );

          return LoadingButton(
            variant: style.signInButtonVariant,
            label: _chooseButtonLabel(),
            isLoading: state is SigningIn || state is SigningUp,
            onTap: _submit,
          );
        },
      ),
      Builder(
        builder: (context) {
          final authState = AuthState.of(context);
          if (authState is AuthFailed) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ErrorText(
                textAlign: TextAlign.center,
                exception: authState.exception,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ];

    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
