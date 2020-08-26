import 'package:flutter/foundation.dart';

typedef TypeCastingLogBuilder = String Function(dynamic original, Type targetType,);

extension CastingExtension on dynamic {

  String castToString({bool log = false, TypeCastingLogBuilder logBuilder,}) {
    if (this is String) { return this; }
    else {
      if (log == true) {
        debugPrint(logBuilder?.call(this, String,) ?? "Called toString() on $this <${this.runtimeType}>",);
      }
      return this.toString();
    }
  }

  int castToInt({int defaultValue, bool log = false, TypeCastingLogBuilder logBuilder,}) {
    int result = defaultValue;
    switch (this.runtimeType) {
      case int: result = this; break;
      case num:
      case double:
        result = (this as num).toInt();
        if (log == true) {
          debugPrint(logBuilder?.call(this, int,) ?? "Casted value of $this <${this.runtimeType}> to $result <int>",);
        }
        break;
      case String:
        result = int.tryParse(this,);
        if (log == true) {
          debugPrint(logBuilder?.call(this, int,) ?? "Parsed String value of \"$this\" as int ($result)",);
        }
        break;
      case bool:
        result = this ? 1 : 0;
        break;
      default:
        if (log == true) {
          debugPrint(logBuilder?.call(this, int,) ?? "Unable to cast $this <${this.runtimeType}> to int",);
        }
        break;
    }
    return result;
  }

  double castToDouble({double defaultValue, bool log = false, TypeCastingLogBuilder logBuilder,}) {
    double result = defaultValue;
    switch (this.runtimeType) {
      case double: result = this; break;
      case num:
      case int:
        result = (this as num).toDouble();
        if (log == true) {
          debugPrint(logBuilder?.call(this, double,) ?? "Casted value of $this <${this.runtimeType}> to $result <double>",);
        }
        break;
      case String:
        result = double.tryParse(this,);
        if (log == true) {
          debugPrint(logBuilder?.call(this, double,) ?? "Parsed String value of \"$this\" as double ($result)",);
        }
        break;
      case bool:
        result = this ? 1.0 : 0.0;
        break;
      default:
        if (log == true) {
          debugPrint(logBuilder?.call(this, double,) ?? "Unable to cast $this <${this.runtimeType}> to double",);
        }
        break;
    }
    return result;
  }

  num castToNum({num defaultValue, bool log = false, TypeCastingLogBuilder logBuilder,}) {
    num result = defaultValue;
    switch (this.runtimeType) {
      case num: result = this; break;
      case String:
        result = num.tryParse(this,);
        if (log == true) {
          debugPrint(logBuilder?.call(this, num,) ?? "Parsed String value of \"$this\" as num ($result)",);
        }
        break;
      case bool:
        result = this ? 1 : 0;
        break;
      default:
        if (log == true) {
          debugPrint(logBuilder?.call(this, num,) ?? "Unable to cast $this <${this.runtimeType}> to num",);
        }
        break;
    }
    return result;
  }

  bool castToBool({
    bool defaultValue,
    bool useStrictFalsyDetection = false,
    bool log = false,
    TypeCastingLogBuilder logBuilder,
  }) {
    bool result = defaultValue;
    switch (this.runtimeType) {
      case bool: result = this; break;
      case num:
        if (useStrictFalsyDetection != true) {
          result = this > 0;
          if (log == true) {
            debugPrint(logBuilder?.call(this, bool,) ?? "Converted $this <${this.runtimeType}> to $result",);
          }
        } else {
          if (log == true) {
            debugPrint(logBuilder?.call(this, bool,) ?? "Unable to convert $this <${this.runtimeType}> to bool",);
          }
        }
        break;
      case String:
        if (useStrictFalsyDetection == true) {
          switch (this.toLowerCase()) {
            case "true": result = true; break;
            case "false": result = false; break;
          }
          if (log == true) {
            debugPrint(logBuilder?.call(this, bool,) ?? "Parsed String value of \"$this\" as bool",);
          }
        } else {
          result = this.trim().isNotEmpty;
          if (log == true) {
            debugPrint(logBuilder?.call(this, bool,) ?? "Converted String value of \"$this\" as [$result] (Loose Rule)",);
          }
        }
        break;
      default:
        if (useStrictFalsyDetection == true) {
          if (log == true) {
            debugPrint(logBuilder?.call(this, bool,) ?? "Unable to cast $this <${this.runtimeType}> to bool",);
          }
        } else {
          result = this != null;
          if (log == true) {
            debugPrint(logBuilder?.call(this, bool,) ?? "Using null checking for unsupported value $this <${this.runtimeType}> for bool value assignment",);
          }
        }
        break;
    }
    return result;
  }
}