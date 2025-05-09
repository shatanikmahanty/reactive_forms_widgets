import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  FormGroup buildForm() => fb.group({
        'input': FormControl<PhoneNumber>(
          value: const PhoneNumber(
            isoCode: IsoCode.UA,
            nsn: '933456789',
          ),
          disabled: true,
          validators: [
            // PhoneValidators.required,
            // PhoneValidators.valid,
          ],
        ),
      });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        ...PhoneFieldLocalization.delegates,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
        Locale('fr', ''),
        Locale('ru', ''),
        Locale('uz', ''),
        Locale('uk', ''),
        Locale('ar', ''),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) {
        return ReactiveFormConfig(
          validationMessages: {
            // either configure validation messages globally, or for each control
            ...PhoneValidationMessage.localizedValidationMessages(context),
          },
          child: child!,
        );
      },
      home: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: ReactiveFormBuilder(
              form: buildForm,
              builder: (context, form, child) {
                return Column(
                  children: [
                    ReactivePhoneFormField<PhoneNumber>(
                      formControlName: 'input',
                      focusNode: FocusNode(),
                      valueAccessor: PhoneNumberValueAccessor(),
                      // validationMessages: {
                      //   ...PhoneValidationMessage.localizedValidationMessages(
                      //     context,
                      //   ),
                      // },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: const Text('Sign Up'),
                      onPressed: () {
                        if (form.valid) {
                          // ignore: avoid_print
                          print(form.value);
                        } else {
                          form.markAllAsTouched();
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
