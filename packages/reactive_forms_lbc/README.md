# reactive_forms_lbc

This is a set of widgets for [`reactive_forms`](https://pub.dev/packages/reactive_forms) package in Listener/Builder/Consumer paradigm the same as bloc library does.

Available widgets:

### Listeners
- ReactiveFormControlStatusListener
- ReactiveFormControlFocusListener
- ReactiveFormControlTouchListener
- ReactiveFormControlValueListener
- ReactiveFormArrayCollectionListener

### Builders
- ReactiveFormControlValueBuilder
- ReactiveFormControlStatusBuilder
- ReactiveFormControlTouchBuilder
- ReactiveFormControlFocusBuilder
- ReactiveFormArrayCollectionBuilder

### Consumers
- ReactiveFormControlValueConsumer
- ReactiveFormControlStatusConsumer
- ReactiveFormControlTouchConsumer
- ReactiveFormControlFocusConsumer
- ReactiveFormArrayCollectionConsumer

## FormArray collection changes

`ReactiveFormArrayCollection*` widgets observe `FormArray.collectionChanges` and report per-item additions and removals with the affected control and its index. Bulk operations (`addAll`, etc.) emit one callback per item, in order.

```dart
ReactiveFormArrayCollectionListener<Map<String, Object?>>(
  formArrayName: 'rows', // or: formArray: myFormArray,
  onItemAdded: (context, array, control, addedIndex) {
    // control is the newly added AbstractControl<Map<String, Object?>>
    // addedIndex is its position in the new controls list
  },
  onItemRemoved: (context, array, control, removedIndex) {
    // control is the removed AbstractControl
    // removedIndex is the position it was at before removal
  },
  child: ...,
)
```

`ReactiveFormArrayCollectionBuilder` rebuilds its `builder: (context, FormArray<T>)` whenever the collection changes; `ReactiveFormArrayCollectionConsumer` combines both. All three accept either `formArrayName` (resolved through the surrounding `ReactiveForm`) or a direct `formArray` reference.

## Getting Started

Run example project to see how it works.
