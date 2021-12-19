using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GdUnit3
{
    public sealed class AssertFailures
    {
        const string WARN_COLOR = "#EFF883";
        const string ERROR_COLOR = "#CD5C5C";
        const string VALUE_COLOR = "#1E90FF";

        private static Func<object, string> defaultFormatter = (value) => value?.ToString() ?? "Null";

        private static Func<object, string> classFormatter = (value) => value?.GetType().Name ?? "Null";
        private static Func<object, string> godotClassFormatter = (value) =>
        {
            if (value != null)
            {
                return ((Godot.Object)value).GetClass();
            }
            return "Null";
        };
        private static Dictionary<Type, Func<object, string>> formatters = new Dictionary<Type, Func<object, string>>{
                {typeof(string), (value) => value?.ToString() ?? "Null"},
                {typeof(object), (value) =>  value?.GetType().Name ?? "Null"},
        };

        private static string SimpleClassName(Type type)
        {
            var sb = new StringBuilder();
            var name = type.FullName;
            if (!type.IsGenericType) return name;
            sb.Append(name.Substring(0, name.IndexOf('`')));
            sb.Append("<");
            sb.Append(string.Join(", ", type.GetGenericArguments().Select(t => SimpleClassName(t))));
            sb.Append(">");
            return sb.ToString();
        }

        private static string FormatValue(object value, string color, bool quoted, string delimiter = "\n")
        {
            if (value == null)
                return "'Null'";

            if (value is Type)
                return string.Format("[color={0}]<{1}>[/color]", VALUE_COLOR, value);

            Type type = value.GetType();
            if (type.IsArray || (value is IEnumerable && !(value is string)))
            {
                var asArray = ((IEnumerable)value).Cast<object>()
                             .Select(x => x.ToString())
                             .ToArray();
                var className = SimpleClassName(type);
                return asArray.Length == 0 ? "empty " + className : className + " [" + string.Join(", ", asArray) + "]";
            }

            if (type.IsClass && !(value is string) || value is Type)
            {
                return string.Format("[color={0}]<{1}>[/color]", VALUE_COLOR, SimpleClassName(type));
            }

            var formatter = type != null && formatters.ContainsKey(type) ? formatters[type] : defaultFormatter;
            string pattern = quoted ? "'[color={0}]{1}[/color]'" : "[color={0}]{1}[/color]";
            return string.Format(pattern, VALUE_COLOR, formatter(value));
        }

        private static string FormatCurrent(object value, string delimiter = "\n") => FormatValue(value, VALUE_COLOR, true);
        private static string FormatExpected(object value) => FormatValue(value, VALUE_COLOR, true);
        private static string FormatFailure(object value) => FormatValue(value, ERROR_COLOR, false);

        public static string Equal(object current, object expected) =>
            string.Format("{0}\n {1}\n but was\n {2}",
                FormatFailure("Expecting:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string NotEqual(object current, object expected) =>
            string.Format("{0}\n {1}\n not equal to\n {2}",
                FormatFailure("Expecting:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsNull(object current) =>
            string.Format("{0} {1} but was {2}",
                FormatFailure("Expecting:"),
                FormatExpected(null),
                FormatCurrent(current));

        public static string IsNotNull(object current) =>
            string.Format("{0} {1}",
                FormatFailure("Expecting: not to be"),
                FormatCurrent(current));

        public static string NotInstanceOf(Type expected) =>
            string.Format("{0} {1}",
                FormatFailure("Expecting: not be a instance of"),
                FormatExpected(expected));

        public static string IsInstanceOf(Type current, Type expected) =>
            string.Format("{0}\n {1}\n But it was {2}",
                FormatFailure("Expected instance of:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsSame(object current, object expected) =>
            string.Format("{0}\n {1}\n to refer to the same object\n {2}",
                FormatFailure("Expecting:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsNotSame(object expected) =>
            string.Format("{0} {1}",
                FormatFailure("Expecting not same:"),
                FormatExpected(expected));
    }
}
