import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:reactive_forms/reactive_forms.dart';

typedef ReactiveFormArrayCollectionItemCallback<T> = void Function(
  BuildContext context,
  FormArray<T> formArray,
  AbstractControl<T> control,
  int index,
);

typedef ReactiveFormArrayCollectionInitListener<T> = void Function(
  FormArray<T> formArray,
);

typedef ReactiveFormArrayCollectionListenerCondition<T> = bool Function(
  FormArray<T> formArray,
  List<AbstractControl<T>> previousControls,
  List<AbstractControl<T>> currentControls,
);

class ReactiveFormArrayCollectionListener<T>
    extends ReactiveFormArrayCollectionListenerBase<T> {
  const ReactiveFormArrayCollectionListener({
    super.key,
    super.formArrayName,
    super.formArray,
    super.onItemAdded,
    super.onItemRemoved,
    super.listenWhen,
    super.listenerOnInit,
    super.child,
  })  : assert(
            (formArrayName != null && formArray == null) ||
                (formArrayName == null && formArray != null),
            'Must provide a formArrayName or a formArray, but not both at the same time.'),
        assert(
            onItemAdded != null ||
                onItemRemoved != null ||
                listenerOnInit != null,
            'Must provide at least one of onItemAdded, onItemRemoved, or listenerOnInit.');
}

abstract class ReactiveFormArrayCollectionListenerBase<T>
    extends SingleChildStatefulWidget {
  const ReactiveFormArrayCollectionListenerBase({
    super.key,
    this.formArrayName,
    this.formArray,
    this.onItemAdded,
    this.onItemRemoved,
    this.listenWhen,
    this.listenerOnInit,
    this.child,
  }) : super(child: child);

  final String? formArrayName;

  final FormArray<T>? formArray;

  final Widget? child;

  final ReactiveFormArrayCollectionItemCallback<T>? onItemAdded;

  final ReactiveFormArrayCollectionItemCallback<T>? onItemRemoved;

  final ReactiveFormArrayCollectionListenerCondition<T>? listenWhen;

  final ReactiveFormArrayCollectionInitListener<T>? listenerOnInit;

  FormArray<T> resolveFormArray(BuildContext context) {
    if (formArray != null) {
      return formArray!;
    }

    final parent = ReactiveForm.of(context, listen: false);

    if (parent == null || parent is! FormControlCollection) {
      throw FormControlParentNotFoundException(this);
    }

    final collection = parent as FormControlCollection;
    final control = collection.control(formArrayName!);

    if (control is! FormArray<T>) {
      throw FormControlNotFoundException(controlName: formArrayName!);
    }

    return control;
  }

  @override
  SingleChildState<ReactiveFormArrayCollectionListenerBase<T>> createState() =>
      ReactiveFormArrayCollectionListenerBaseState<T>();
}

class ReactiveFormArrayCollectionListenerBaseState<T>
    extends SingleChildState<ReactiveFormArrayCollectionListenerBase<T>> {
  StreamSubscription<List<AbstractControl<Object?>>>? _subscription;
  late FormArray<T> _formArray;
  late List<AbstractControl<T>> _previousControls;

  @override
  void initState() {
    super.initState();
    _formArray = widget.resolveFormArray(context);
    _previousControls = _snapshotControls(_formArray);
    widget.listenerOnInit?.call(_formArray);
    _subscribe();
  }

  @override
  void didUpdateWidget(ReactiveFormArrayCollectionListenerBase<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldArray = oldWidget.resolveFormArray(context);
    final currentArray = widget.resolveFormArray(context);

    if (oldArray != currentArray) {
      if (_subscription != null) {
        _unsubscribe();
        _formArray = currentArray;
        _previousControls = _snapshotControls(_formArray);
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final array = widget.resolveFormArray(context);
    if (_formArray != array) {
      if (_subscription != null) {
        _unsubscribe();
        _formArray = array;
        _previousControls = _snapshotControls(_formArray);
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _formArray.collectionChanges.listen((controls) {
      if (!mounted) return;
      final current = List<AbstractControl<T>>.from(
        controls.cast<AbstractControl<T>>(),
        growable: false,
      );
      _processCollectionChange(current);
    });
  }

  void _processCollectionChange(List<AbstractControl<T>> current) {
    final previous = _previousControls;

    final shouldEmit =
        widget.listenWhen?.call(_formArray, previous, current) ?? true;

    if (!shouldEmit) {
      _previousControls = List<AbstractControl<T>>.unmodifiable(current);
      return;
    }

    for (var i = 0; i < previous.length; i++) {
      final ctrl = previous[i];
      final stillPresent = current.any((c) => identical(c, ctrl));
      if (!stillPresent) {
        widget.onItemRemoved?.call(context, _formArray, ctrl, i);
      }
    }

    for (var i = 0; i < current.length; i++) {
      final ctrl = current[i];
      final wasPresent = previous.any((c) => identical(c, ctrl));
      if (!wasPresent) {
        widget.onItemAdded?.call(context, _formArray, ctrl, i);
      }
    }

    _previousControls = List<AbstractControl<T>>.unmodifiable(current);
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  static List<AbstractControl<T>> _snapshotControls<T>(FormArray<T> array) =>
      List<AbstractControl<T>>.unmodifiable(array.controls);
}
