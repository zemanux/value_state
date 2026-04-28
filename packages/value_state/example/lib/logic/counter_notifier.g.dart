// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myRepository)
final myRepositoryProvider = MyRepositoryProvider._();

final class MyRepositoryProvider
    extends $FunctionalProvider<MyRepository, MyRepository, MyRepository>
    with $Provider<MyRepository> {
  MyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myRepositoryHash();

  @$internal
  @override
  $ProviderElement<MyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MyRepository create(Ref ref) {
    return myRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MyRepository>(value),
    );
  }
}

String _$myRepositoryHash() => r'f60f56f53e1042b2719118d50e02a2134f095fd5';

@ProviderFor(counter)
final counterProvider = CounterProvider._();

final class CounterProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  CounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return counter(ref);
  }
}

String _$counterHash() => r'f915d09ac88f54b0ee6665ded639a2958c7461b4';
