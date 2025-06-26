import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/user.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class UserEditorModal extends StatefulWidget {
  User user;
  bool editing;

  UserEditorModal({super.key, required this.user, this.editing = false});

  @override
  State<UserEditorModal> createState() => _UserEditorModalState();
}

class _UserEditorModalState extends State<UserEditorModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();

  int? currentRoleId;

  final List<String> _superUsersPermissions = [
    'ALLOW_VIEW_USERS',
    'ALLOW_EDIT_COMPANY',
    'ALLOW_VIEW_CREATE_SALE_SERVICE',
    'ALLOW_VIEW_CREATE_SALE_PRODUCT',
    'ALLOW_VIEW_CREATE_CREDIT_NOTE_SERVICE',
    'ALLOW_VIEW_CREATE_CREDIT_NOTE_PRODUCT',
    'ALLOW_VIEW_SALES',
    'ALLOW_VIEW_CREDIT_NOTES',
    'ALLOW_VIEW_SERVICES',
    'ALLOW_VIEW_PRODUCTS',
    'ALLOW_VIEW_CLIENTS',
    'ALLOW_VIEW_CREATE_FORM_607',
  ];

  final List<String> _adminPermissions = [
    'ALLOW_VIEW_USERS',
    'ALLOW_EDIT_COMPANY',
    'ALLOW_VIEW_CREATE_SALE_SERVICE',
    'ALLOW_VIEW_CREATE_SALE_PRODUCT',
    'ALLOW_VIEW_CREATE_CREDIT_NOTE_SERVICE',
    'ALLOW_VIEW_CREATE_CREDIT_NOTE_PRODUCT',
    'ALLOW_VIEW_SALES',
    'ALLOW_VIEW_CREDIT_NOTES',
    'ALLOW_VIEW_SERVICES',
    'ALLOW_VIEW_PRODUCTS',
    'ALLOW_VIEW_CLIENTS',
    'ALLOW_VIEW_CREATE_FORM_607',
    'ALLOW_VIEW_ELECTRONIC_SETTINGS'
  ];

  final List<String> _cashierPermissions = [
    'ALLOW_VIEW_CREATE_SALE_SERVICE',
    'ALLOW_VIEW_CREATE_SALE_PRODUCT',
    'ALLOW_VIEW_CREATE_CREDIT_NOTE_SERVICE',
    'ALLOW_VIEW_CREATE_CREDIT_NOTE_PRODUCT',
    'ALLOW_VIEW_SALES',
    'ALLOW_VIEW_CREDIT_NOTES',
    'ALLOW_VIEW_SERVICES',
    'ALLOW_VIEW_PRODUCTS',
    'ALLOW_VIEW_CLIENTS',
    'ALLOW_VIEW_CREATE_FORM_607',
  ];
  List<String> _userPermissions = [];

  String get title {
    return widget.editing ? 'EDITANDO USUARIO...' : 'CREANDO USUARIO...';
  }

  String get btnTitle {
    return widget.editing ? 'EDITAR USUARIO' : 'CREAR USUARIO';
  }

  bool get isReadOnlySuperUser {
    if (widget.editing) {
      if (currentUser?.roleId == 1) return true;
      if (currentUser?.roleId == 2 && widget.user.roleId == 3) return true;
      if (currentUser?.id == widget.user.id && widget.user.roleId == 3) {
        return true;
      }
    }
    return false;
  }

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        widget.user.name = name.text;
        widget.user.username = username.text;

        widget.user.password = password.text;

        widget.user.phone = phone.text;
        widget.user.email = email.text;
        widget.user.roleId = currentRoleId;

        widget.user.permissions = _userPermissions;
        if (!widget.editing) {
          await widget.user.create();
        } else {
          await widget.user.update();
          if (currentUser?.id == widget.user.id) {
            currentUser?.name = widget.user.name;
            currentUser?.username = widget.user.username;
            currentUser?.roleId = widget.user.roleId;
            currentUser?.roleName = widget.user.roleName;
            currentUser?.permissions = _userPermissions;
          }
        }
        Navigator.pop(context, widget.editing ? 'UPDATE' : 'CREATE');
        showTopSnackBar(context,
            message: widget.editing ? 'USUARIO EDITADO' : 'USUARIO CREADO',
            color: Colors.green);
      } catch (e) {
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  @override
  void initState() {
    if (widget.editing) {
      _userPermissions = [...widget.user.permissions ?? []];
      username.value = TextEditingValue(text: widget.user.username ?? '');
      name.value = TextEditingValue(text: widget.user.name ?? '');
      phone.value = TextEditingValue(text: widget.user.phone ?? '');
      email.value = TextEditingValue(text: widget.user.email ?? '');
      currentRoleId = widget.user.roleId;
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
          width: 400,
          height: 600,
          child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                  padding: EdgeInsets.all(kDefaultPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor))),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
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
                            TextFormField(
                              controller: name,
                              validator: (val) =>
                                  val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                              decoration: InputDecoration(
                                  labelText: 'NOMBRE',
                                  hintText: 'Escribir algo...'),
                            ),
                            SizedBox(
                              height: kDefaultPadding,
                            ),
                            DropdownButtonFormField<int>(
                                value: currentRoleId,
                                validator: (val) =>
                                    val == null ? 'CAMPO OBLIGATORIO' : null,
                                decoration: InputDecoration(labelText: 'ROL'),
                                items: List.generate(roles.length, (index) {
                                  var role = roles[index];
                                  return DropdownMenuItem(
                                      value: role.id,
                                      child: Text(role.name ?? ''));
                                }),
                                onChanged: isReadOnlySuperUser
                                    ? null
                                    : (option) {
                                        currentRoleId = option;

                                        if (currentRoleId == 1) {
                                          _userPermissions =
                                              _cashierPermissions;
                                        }
                                        if (currentRoleId == 2) {
                                          _userPermissions = _adminPermissions;
                                        }
                                        if (currentRoleId == 3) {
                                          _userPermissions =
                                              _superUsersPermissions;
                                        }
                                        setState(() {});
                                      }),
                            widget.editing
                                ? SizedBox(height: kDefaultPadding)
                                : Column(
                                    children: [
                                      SizedBox(height: kDefaultPadding),
                                      TextFormField(
                                        controller: password,
                                        validator: (val) => val!.isEmpty
                                            ? 'CAMPO OBLIGATORIO'
                                            : null,
                                        decoration: InputDecoration(
                                            labelText: 'CLAVE',
                                            hintText: 'Escribir algo...'),
                                      ),
                                      SizedBox(height: kDefaultPadding),
                                    ],
                                  ),
                            TextFormField(
                              controller: phone,
                              decoration: InputDecoration(
                                  labelText: 'TELEFONO',
                                  hintText: 'Escribir algo...'),
                            ),
                            SizedBox(height: kDefaultPadding),
                            TextFormField(
                              controller: email,
                              decoration: InputDecoration(
                                  labelText: 'CORREO',
                                  hintText: 'Escribir algo...'),
                            ),
                            SizedBox(height: kDefaultPadding),
                            Opacity(
                                opacity: isReadOnlySuperUser ? 0.5 : 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...List.generate(permissions.length,
                                        (index) {
                                      var permission = permissions[index];
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Checkbox.adaptive(
                                                value: _userPermissions
                                                    .contains(permission.name),
                                                onChanged: (val) {
                                                  if (isReadOnlySuperUser) {
                                                    return;
                                                  }
                                                  if (!val!) {
                                                    _userPermissions
                                                        .removeWhere((e) =>
                                                            e ==
                                                            permission.name);
                                                  } else {
                                                    _userPermissions.add(
                                                        permission.name ?? '');
                                                  }
                                                  setState(() {});
                                                }),
                                            title: Text(
                                                permission.displayName ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium),
                                          ),
                                          const Divider()
                                        ],
                                      );
                                    }),
                                  ],
                                ))
                          ],
                        ),
                      )),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: _onSubmit, child: Text(btnTitle)),
                      )
                    ],
                  )))),
    );
  }
}
