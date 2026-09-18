import "dart:convert";
import "dart:developer";

class PrettyPrintUtil {
  PrettyPrintUtil._();

  static final PrettyPrintUtil instance = PrettyPrintUtil._();

  String prettyPrint(final Map<String, dynamic> map) {
    String value = "";

    try {
      value = const JsonEncoder.withIndent("  ").convert(map);
    } on Exception catch (error, stack) {
      log("Failure in prettyPrint", error: error, stackTrace: stack);
    }

    return value;
  }
}
