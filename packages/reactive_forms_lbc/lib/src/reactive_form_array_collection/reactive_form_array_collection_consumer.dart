import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_forms_lbc/src/reactive_form_array_collection/reactive_form_array_collection_builder.dart';
import 'package:reactive_forms_lbc/src/reactive_form_array_collection/reactive_form_array_collection_listener.dart';

class ReactiveFormArrayCollectionConsumer<T> extends StatelessWidget {
  const ReactiveFormArrayCollectionConsumer({
    super.key,
    required this.builder,
    this.formArrayName,
    this.formArray,
    this.onItemAdded,
    this.onItemRemoved,
    this.listenerOnInit,
    this.buildWhen,
    this.listenWhen,
  }) : assert(
            (formArrayName != null && formArray == null) ||
                (formArrayName == null && formArray != null),
            'Must provide a formArrayName or a formArray, but not both at the same time.');

  final String? formArrayName;

  final FormArray<T>? formArray;

  final ReactiveFormArrayCollectionWidgetBuilder<T> builder;

  final ReactiveFormArrayCollectionItemCallback<T>? onItemAdded;

  final ReactiveFormArrayCollectionItemCallback<T>? onItemRemoved;

  final ReactiveFormArrayCollectionInitListener<T>? listenerOnInit;

  final ReactiveFormArrayCollectionBuilderCondition<T>? buildWhen;

  final ReactiveFormArrayCollectionListenerCondition<T>? listenWhen;

  @override
  Widget build(BuildContext context) {
    final builderWidget = ReactiveFormArrayCollectionBuilder<T>(
      formArrayName: formArrayName,
      formArray: formArray,
      buildWhen: buildWhen,
      builder: builder,
    );

    if (onItemAdded == null &&
        onItemRemoved == null &&
        listenerOnInit == null) {
      return builderWidget;
    }

    return ReactiveFormArrayCollectionListener<T>(
      formArrayName: formArrayName,
      formArray: formArray,
      listenWhen: listenWhen,
      listenerOnInit: listenerOnInit,
      onItemAdded: onItemAdded,
      onItemRemoved: onItemRemoved,
      child: builderWidget,
    );
  }
}
