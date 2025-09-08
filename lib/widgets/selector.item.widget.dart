import 'package:flutter/material.dart';

import 'package:uresax_invoice_sys/settings.dart';

class SelectorItemWidget<T> extends FormField<T> {
  SelectorItemWidget(
      {super.key,
      required BuildContext context,
      required String title,
      required Widget screen,
      required void Function(T?) onChanged,
      super.initialValue,
      super.validator,
      super.autovalidateMode = AutovalidateMode.disabled,
      super.enabled = true})
      : super(builder: (state) {
          dynamic value = state.value ?? initialValue;
          String val = value?.name ?? title;
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: state.hasError
                                ? Theme.of(context).colorScheme.error
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(20)),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: Ink(
                        child: InkWell(
                            onTap: !enabled
                                ? null
                                : () async {
                                    var res = await Navigator.push<T>(
                                        context,
                                        MaterialPageRoute(
                                            builder: (ctx) => screen));
                                    if (res != null) {
                                      state.didChange(res);
                                      state.save();
                                      state.validate();
                                      onChanged(res);
                                    }
                                  },
                            child: Padding(
                                padding: EdgeInsets.all(kDefaultPadding * 0.8),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      val,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    Icon(Icons.arrow_drop_down,
                                        color: Colors.black45)
                                  ],
                                ))),
                      ),
                    )),
                state.hasError
                    ? Container(
                        margin: EdgeInsets.only(
                            top: kDefaultPadding / 2,
                            left: kDefaultPadding / 2),
                        child: Text(state.errorText ?? '',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 15)),
                      )
                    : SizedBox()
              ],
            ),
          );
        });
}
