// Mocks generated by Mockito 5.4.5 from annotations
// in link_shortener/test/mock/mock_services.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:flutter/material.dart' as _i7;
import 'package:link_shortener/models/auth/oauth_provider.dart' as _i10;
import 'package:link_shortener/models/auth/user.dart' as _i11;
import 'package:link_shortener/models/auth/user_session.dart' as _i9;
import 'package:link_shortener/models/short_url.dart' as _i2;
import 'package:link_shortener/models/ttl.dart' as _i8;
import 'package:link_shortener/services/auth_service.dart' as _i3;
import 'package:link_shortener/services/recaptcha_service.dart' as _i12;
import 'package:link_shortener/services/url_service.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeShortUrl_0 extends _i1.SmartFake implements _i2.ShortUrl {
  _FakeShortUrl_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeAuthResult_1 extends _i1.SmartFake implements _i3.AuthResult {
  _FakeAuthResult_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [UrlService].
///
/// See the documentation for Mockito's code generation for more information.
class MockUrlService extends _i1.Mock implements _i4.UrlService {
  MockUrlService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<String> shortenRestrictedUrl(String? url) =>
      (super.noSuchMethod(
            Invocation.method(#shortenRestrictedUrl, [url]),
            returnValue: _i5.Future<String>.value(
              _i6.dummyValue<String>(
                this,
                Invocation.method(#shortenRestrictedUrl, [url]),
              ),
            ),
          )
          as _i5.Future<String>);

  @override
  _i5.Future<String> createShortUrl({
    _i7.BuildContext? context,
    required String? url,
    required _i8.TTL? ttl,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#createShortUrl, [], {
              #context: context,
              #url: url,
              #ttl: ttl,
            }),
            returnValue: _i5.Future<String>.value(
              _i6.dummyValue<String>(
                this,
                Invocation.method(#createShortUrl, [], {
                  #context: context,
                  #url: url,
                  #ttl: ttl,
                }),
              ),
            ),
          )
          as _i5.Future<String>);

  @override
  _i5.Future<List<_i2.ShortUrl>> getUserUrls({_i7.BuildContext? context}) =>
      (super.noSuchMethod(
            Invocation.method(#getUserUrls, [], {#context: context}),
            returnValue: _i5.Future<List<_i2.ShortUrl>>.value(<_i2.ShortUrl>[]),
          )
          as _i5.Future<List<_i2.ShortUrl>>);

  @override
  _i5.Future<_i2.ShortUrl> getUrlDetails(
    String? shortId, {
    _i7.BuildContext? context,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getUrlDetails, [shortId], {#context: context}),
            returnValue: _i5.Future<_i2.ShortUrl>.value(
              _FakeShortUrl_0(
                this,
                Invocation.method(
                  #getUrlDetails,
                  [shortId],
                  {#context: context},
                ),
              ),
            ),
          )
          as _i5.Future<_i2.ShortUrl>);

  @override
  _i5.Future<bool> deleteUrl(String? shortId, {_i7.BuildContext? context}) =>
      (super.noSuchMethod(
            Invocation.method(#deleteUrl, [shortId], {#context: context}),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<_i2.ShortUrl> updateUrl({
    required String? shortId,
    String? customAlias,
    DateTime? expiresAt,
    _i7.BuildContext? context,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#updateUrl, [], {
              #shortId: shortId,
              #customAlias: customAlias,
              #expiresAt: expiresAt,
              #context: context,
            }),
            returnValue: _i5.Future<_i2.ShortUrl>.value(
              _FakeShortUrl_0(
                this,
                Invocation.method(#updateUrl, [], {
                  #shortId: shortId,
                  #customAlias: customAlias,
                  #expiresAt: expiresAt,
                  #context: context,
                }),
              ),
            ),
          )
          as _i5.Future<_i2.ShortUrl>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [AuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthService extends _i1.Mock implements _i3.AuthService {
  MockAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Stream<_i9.UserSession?> get authStateChanges =>
      (super.noSuchMethod(
            Invocation.getter(#authStateChanges),
            returnValue: _i5.Stream<_i9.UserSession?>.empty(),
          )
          as _i5.Stream<_i9.UserSession?>);

  @override
  bool get isAuthenticated =>
      (super.noSuchMethod(
            Invocation.getter(#isAuthenticated),
            returnValue: false,
          )
          as bool);

  @override
  _i5.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> initLocalStorage() =>
      (super.noSuchMethod(
            Invocation.method(#initLocalStorage, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> saveSession(_i9.UserSession? session) =>
      (super.noSuchMethod(
            Invocation.method(#saveSession, [session]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> signInWithOAuth(
    _i10.OAuthProvider? provider, {
    _i7.BuildContext? context,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #signInWithOAuth,
              [provider],
              {#context: context},
            ),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<bool> refreshToken({_i7.BuildContext? context}) =>
      (super.noSuchMethod(
            Invocation.method(#refreshToken, [], {#context: context}),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<void> signOut({_i7.BuildContext? context}) =>
      (super.noSuchMethod(
            Invocation.method(#signOut, [], {#context: context}),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<_i3.AuthResult> getUserProfileWithAuthStatus({
    _i7.BuildContext? context,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getUserProfileWithAuthStatus, [], {
              #context: context,
            }),
            returnValue: _i5.Future<_i3.AuthResult>.value(
              _FakeAuthResult_1(
                this,
                Invocation.method(#getUserProfileWithAuthStatus, [], {
                  #context: context,
                }),
              ),
            ),
          )
          as _i5.Future<_i3.AuthResult>);

  @override
  _i5.Future<Map<String, String>> getAuthHeaders({_i7.BuildContext? context}) =>
      (super.noSuchMethod(
            Invocation.method(#getAuthHeaders, [], {#context: context}),
            returnValue: _i5.Future<Map<String, String>>.value(
              <String, String>{},
            ),
          )
          as _i5.Future<Map<String, String>>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  _i5.Future<_i11.User?> getUserProfile() =>
      (super.noSuchMethod(
            Invocation.method(#getUserProfile, []),
            returnValue: _i5.Future<_i11.User?>.value(),
          )
          as _i5.Future<_i11.User?>);

  @override
  _i5.Future<Map<String, dynamic>> handleOAuthSuccessCallback(Uri? uri) =>
      (super.noSuchMethod(
            Invocation.method(#handleOAuthSuccessCallback, [uri]),
            returnValue: _i5.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i5.Future<Map<String, dynamic>>);
}

/// A class which mocks [RecaptchaService].
///
/// See the documentation for Mockito's code generation for more information.
class MockRecaptchaService extends _i1.Mock implements _i12.RecaptchaService {
  MockRecaptchaService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<String> execute(String? action) =>
      (super.noSuchMethod(
            Invocation.method(#execute, [action]),
            returnValue: _i5.Future<String>.value(
              _i6.dummyValue<String>(
                this,
                Invocation.method(#execute, [action]),
              ),
            ),
          )
          as _i5.Future<String>);
}
