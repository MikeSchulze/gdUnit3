using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace GdUnit3
{
    public sealed class AssertFailures
    {
        const string WARN_COLOR = "#EFF883";
        const string ERROR_COLOR = "#CD5C5C";
        const string VALUE_COLOR = "#1E90FF";

        private static Func<object, string> defaultFormatter = (value) => value?.ToString() ?? "Null";
        private static Dictionary<Type, Func<object, string>> formatters = new Dictionary<Type, Func<object, string>>{
                {typeof(string), (value) => value?.ToString() ?? "Null"},
                {typeof(object), (value) =>  value?.GetType().Name ?? "Null"},
        };

        private static string FormatValue(object value, string color, bool quoted, string delimiter = "\n")
        {
            if (value == null)
                return "'Null'";

            Type type = value.GetType();
            if (type.IsArray || (value is IEnumerable && !(value is string)))
            {
                var asArray = ((IEnumerable)value).Cast<object>()
                             .Select(x => x.ToString())
                             .ToArray();
                return "[" + string.Join(", ", asArray) + "]";
            }

            var formatter = type != null && formatters.ContainsKey(type) ? formatters[type] : defaultFormatter;
            string pattern = quoted ? "'[color={0}]{1}[/color]'" : "[color={0}]{1}[/color]";
            return string.Format(pattern, VALUE_COLOR, formatter(value));
        }

        private static string FormatCurrent(object value, string delimiter = "\n") => FormatValue(value, VALUE_COLOR, true);
        private static string FormatExpected(object value) => FormatValue(value, VALUE_COLOR, true);
        private static string FormatError(object value) => FormatValue(value, ERROR_COLOR, false);

        public static string ErrorEqual(object current, object expected)
        {
            return string.Format("{0}\n {1}\n but was\n {2}",
                FormatError("Expecting:"),
                FormatExpected(expected),
                FormatCurrent(current));
        }

        public static string ErrorNotEqual(object current, object expected)
        {
            return string.Format("{0}\n {1}\n not equal to\n {2}",
                FormatError("Expecting:"),
                FormatExpected(expected),
                FormatCurrent(current));
        }

        public static string ErrorIsInstanceOf(Type current, Type expected)
        {
            return string.Format("{0}\n {1}\n But it was {2}",
                FormatError("Expected instance of:"),
                FormatExpected(expected),
                FormatCurrent(current));
        }
    }
}
