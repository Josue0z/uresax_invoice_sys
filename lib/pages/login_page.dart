import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/apis/log.handler.dart' show LogHandler;
import 'package:uresax_invoice_sys/models/user.dart';
import 'package:uresax_invoice_sys/pages/home_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/widgets/password.editor.widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        currentUser = await User.login(username.text, password.text);
        LogHandler.printEvent('EL USUARIO: ${currentUser?.name} INICIO SESION');
        await Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (ctx) => HomePage()), (_) => false);
      } catch (e) {
        LogHandler.printError(e.toString());
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACCEDER',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor)),
                        SizedBox(
                          height: kDefaultPadding,
                        ),
                        TextFormField(
                          controller: username,
                          validator: (val) =>
                              val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                          decoration: InputDecoration(
                              labelText: 'USUARIO',
                              hintText: 'Escribir algo...'),
                        ),
                        SizedBox(
                          height: kDefaultPadding,
                        ),
                        PasswordEditorWidget(
                          controller: password,
                          onFieldSubmitted: (_) => _onSubmit(),
                        ),
                        SizedBox(
                          height: kDefaultPadding,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: _onSubmit, child: Text('INICIAR')),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
