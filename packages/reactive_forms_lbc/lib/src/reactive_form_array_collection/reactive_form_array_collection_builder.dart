import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_forms_lbc/src/reactive_form_array_collection/reactive_form_array_collection_listener.dart';

typedef ReactiveFormArrayCollectionWidgetBuilder<T> = Widget Function(
  BuildContext context,
  FormArray<T> formArray,
);

typedef ReactiveFormArrayCollectionBuilderCondition<T> = bool Function(
  FormArray<T> formArray,
  List<AbstractControl<T>> previousControls,
  List<AbstractControl<T>> currentControls,
);

class ReactiveFormArrayCollectionBuilder<T>
    extends ReactiveFormArrayCollectionBuilderBase<T> {
  const ReactiveFormArrayCollectionBuilder({
    super.key,
    required this.builder,
    super.formArrayName,
    super.formArray,
    super.buildWhen,
  }) : assert(
            (formArrayName != null && formArray == null) ||
                (formArrayName == null && formArray != null),
            'Must provide a formArrayName or a formArray, but not both at the same time.');

  final ReactiveFormArrayCollectionWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context, FormArray<T> formArray) =>
      builder(context, formArray);
}

abstract class ReactiveFormArrayCollectionBuilderBase<T>
    extends StatefulWidget {
  const ReactiveFormArrayCollectionBuilderBase({
    super.key,
    this.formArrayName,
    this.formArray,
    this.buildWhen,
  });

  final String? formArrayName;

  final FormArray<T>? formArray;

  final ReactiveFormArrayCollectionBuilderCondition<T>? buildWhen;

  Widget build(BuildContext context, FormArray<T> formArray);

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
  State<ReactiveFormArrayCollectionBuilderBase<T>> createState() =>
      ReactiveFormArrayCollectionBuilderBaseState<T>();
}

class ReactiveFormArrayCollectionBuilderBaseState<T>
    extends State<ReactiveFormArrayCollectionBuilderBase<T>> {
  late FormArray<T> _formArray;

  @override
  void initState() {
    super.initState();
    _formArray = widget.resolveFormArray(context);
  }

  @override
  void didUpdateWidget(ReactiveFormArrayCollectionBuilderBase<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldArray = oldWidget.resolveFormArray(context);
    final currentArray = widget.resolveFormArray(context);
    if (oldArray != currentArray) {
      _formArray = currentArray;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final array = widget.resolveFormArray(context);
    if (_formArray != array) {
      _formArray = array;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormArrayCollectionListener<T>(
      formArray: _formArray,
      listenWhen: widget.buildWhen,
      listenerOnInit: (_) {},
      onItemAdded: (_, array, __, ___) => setState(() => _formArray = array),
      onItemRemoved: (_, array, __, ___) => setState(() => _formArray = array),
      child: widget.build(context, _formArray),
    );
  }
}
