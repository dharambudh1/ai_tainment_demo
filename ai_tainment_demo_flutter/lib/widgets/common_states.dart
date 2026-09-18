import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:super_paging/super_paging.dart";

Widget loadingBuilder(BuildContext? context) {
  return const Center(child: CupertinoActivityIndicator());
}

Widget emptyBuilder(BuildContext context) {
  return const Center(child: Text("List is currently empty"));
}

Widget errorBuilder(BuildContext context, Object? error) {
  return const Center(child: Icon(Icons.error_outline, size: 16));
}

Widget prependStateBuilder(
  BuildContext context,
  LoadState state,
  Pager<dynamic, dynamic> pager,
) {
  switch (state) {
    case NotLoading():
      return const SizedBox();

    case Loading():
      return loadingBuilder(context);

    case Error():
      return errorBuilder(context, state.error);
  }
}

Widget appendStateBuilder(
  BuildContext context,
  LoadState state,
  Pager<dynamic, dynamic> pager,
) {
  switch (state) {
    case NotLoading():
      return const SizedBox();

    case Loading():
      return loadingBuilder(context);

    case Error():
      return errorBuilder(context, state.error);
  }
}
