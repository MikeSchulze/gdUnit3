using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GdUnit3.Asserts
{
    internal sealed class AssertFailures
    {
        public const string WARN_COLOR = "#EFF883";
        public const string ERROR_COLOR = "#CD5C5C";
        public const string VALUE_COLOR = "#1E90FF";

        private static Func<object, string> defaultFormatter = (value) => value?.ToString() ?? "<Null>";

        private static Func<object, string> classFormatter = (value) => value?.GetType().Name ?? "<Null>";
        private static Func<object, string> godotClassFormatter = (value) =>
        {
            if (value != null)
            {
                return ((Godot.Object)value).GetClass();
            }
            return "Null";
        };

        private static Dictionary<Type, Func<object, string>> formatters = new Dictionary<Type, Func<object, string>>{
                {typeof(string), (value) => value?.ToString() ?? "<Null>"},
                {typeof(object), (value) =>  value?.GetType().Name ?? "<Null>"},
        };

        private static string SimpleClassName(Type type)
        {
            var sb = new StringBuilder();
            var name = type.FullName.Replace("[", "").Replace("]", "");
            if (!type.IsGenericType) return name;
            sb.Append(name.Substring(0, name.IndexOf('`')));
            sb.Append("<");
            sb.Append(string.Join(", ", type.GetGenericArguments().Select(t => SimpleClassName(t))));
            sb.Append(">");
            return sb.ToString();
        }

        public static string FormatValue(object? value, string color, bool quoted, bool printType = true)
        {
            if (value == null)
                return "<Null>";

            if (value is Type)
                return string.Format("[color={0}]<{1}>[/color]", color, value);

            Type type = value.GetType();
            if (type.IsArray || (value is IEnumerable && !(value is string)))
            {
                var asArray = ((IEnumerable)value).Cast<object>()
                             .Select(x => x?.ToString() ?? "<Null>")
                             .ToArray();
                var className = printType ? SimpleClassName(type) : "";
                return asArray.Length == 0
                    ? className + (type.IsArray || value is Godot.Collections.Array ? "[]" : "")
                    : className + "[color=" + color + "][" + string.Join(", ", asArray) + "][/color]";
            }

            if (type.IsClass && !(value is string) || value is Type)
                return string.Format("[color={0}]<{1}>[/color]", color, SimpleClassName(type));

            var formatter = type != null && formatters.ContainsKey(type) ? formatters[type] : defaultFormatter;
            string pattern = quoted ? "'[color={0}]{1}[/color]'" : "[color={0}]{1}[/color]";
            return string.Format(pattern, color, formatter(value));
        }

        private static string FormatCurrent(object? value, bool printType = true) => FormatValue(value, VALUE_COLOR, true, printType);
        private static string FormatExpected(object? value, bool printType = true) => FormatValue(value, VALUE_COLOR, true, printType);
        private static string FormatFailure(object value) => FormatValue(value, ERROR_COLOR, false);

        public static string IsTrue() =>
            string.Format("{0} {1} but is {2}",
                FormatFailure("Expecting:"),
                FormatExpected(true),
                FormatCurrent(false));

        public static string IsFalse() =>
            string.Format("{0} {1} but is {2}",
                FormatFailure("Expecting:"),
                FormatExpected(false),
                FormatCurrent(true));

        public static string IsEqual(object? current, object? expected) =>
            current is IEnumerable || expected is IEnumerable ?
                string.Format("{0}\n  {1}\n but is\n  {2}",
                    FormatFailure("Expecting be equal:"),
                    FormatExpected(expected),
                    FormatCurrent(current))
                :
                string.Format("{0}\n  {1} but is {2}",
                    FormatFailure("Expecting be equal:"),
                    FormatExpected(expected),
                    FormatCurrent(current));

        public static string IsEqual(IEnumerable current, IEnumerable expected) =>
            string.Format("{0}\n  {1}\n  but is\n  {2}",
                FormatFailure("Expecting be equal:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsEqualIgnoringCase(object? current, object expected) =>
            string.Format("{0}\n  {1}\n but is\n  {2}",
                FormatFailure("Expecting be equal (ignoring case):"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsNotEqual(object? current, object? expected) =>
            current is IEnumerable || expected is IEnumerable ?
                string.Format("{0}\n  {1}\n but is\n  {2}",
                    FormatFailure("Expecting be NOT equal:"),
                    FormatExpected(expected),
                    FormatCurrent(current))
                :
                string.Format("{0}\n  {1} but is {2}",
                    FormatFailure("Expecting be NOT equal:"),
                    FormatExpected(expected),
                    FormatCurrent(current));

        public static string IsNotEqual(IEnumerable current, IEnumerable expected) =>
            string.Format("{0}\n  {1}\n but is\n  {2}",
                FormatFailure("Expecting be NOT equal:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsNotEqualIgnoringCase(object? current, object expected) =>
            string.Format("{0}\n  {1}\n but is\n  {2}",
                FormatFailure("Expecting be NOT equal (ignoring case):"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsNull(object current) =>
            string.Format("{0}\n but is\n  {1}",
                FormatFailure("Expecting be <Null>:"),
                FormatCurrent(current));

        public static string IsNotNull(object? current) =>
            string.Format("{0}",
                FormatFailure("Expecting be NOT <Null>:"),
                FormatCurrent(current));

        public static string IsEmpty(int size, bool isNull) =>
            isNull ?
                string.Format("{0}\n but is <Null>", FormatFailure("Expecting be empty:"))
                :
                string.Format("{0}\n but has size {1}", FormatFailure("Expecting be empty:"), FormatCurrent(size));

        public static string IsEmpty(string? current) =>
            string.Format("{0}\n but is\n  {1}",
                FormatFailure("Expecting be empty:"),
                FormatCurrent(current));

        public static string IsNotEmpty() =>
            string.Format("{0}\n but is empty",
                FormatFailure("Expecting being NOT empty:"));

        public static string NotInstanceOf(Type? expected) =>
            string.Format("{0}\n  {1}",
                FormatFailure("Expecting be NOT a instance of:"),
                FormatExpected(expected));

        public static string IsInstanceOf(Type? current, Type expected) =>
            string.Format("{0}\n  {1} but is {2}",
                FormatFailure("Expected be instance of:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsSame(object? current, object expected) =>
            string.Format("{0}\n  {1}\n to refer to the same object\n  {2}",
                FormatFailure("Expecting be same:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsNotSame(object? expected) =>
            string.Format("{0} {1}",
                FormatFailure("Expecting be NOT same:"),
                FormatExpected(expected));

        public static string IsBetween(object? current, object from, object to) =>
            string.Format("{0}\n  {1}\n in range between\n  {2} <> {3}",
                FormatFailure("Expecting:"),
                FormatCurrent(current),
                FormatExpected(from),
                FormatExpected(to));

        public static string IsEven(object? current) =>
            string.Format("{0}\n but is {1}",
                FormatFailure("Expecting be even:"),
                FormatCurrent(current));

        public static string IsOdd(object? current) =>
            string.Format("{0}\n but is {1}",
                FormatFailure("Expecting be odd:"),
                FormatCurrent(current));

        public static string HasSize(object current, object expected) =>
            string.Format("{0}\n  {1} but is {2}",
                FormatFailure("Expecting size:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsGreater(object current, object expected) =>
            string.Format("{0}\n  {1} but is {2}",
                FormatFailure("Expecting to be greater than:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsGreaterEqual(object current, object expected) =>
            string.Format("{0}\n  {1} but is {2}",
                FormatFailure("Expecting to be greater than or equal:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsLess(object current, object expected) =>
            string.Format("{0}\n  {1} but is {2}",
                FormatFailure("Expecting to be less than:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsLessEqual(object current, object expected) =>
            string.Format("{0}\n  {1} but is {2}",
                FormatFailure("Expecting to be less than or equal:"),
                FormatExpected(expected),
                FormatCurrent(current));

        public static string IsNegative(object current) =>
            string.Format("{0}\n but is {1}",
                FormatFailure("Expecting be negative:"),
                FormatCurrent(current));

        public static string IsNotNegative(object current) =>
            string.Format("{0}\n but is {1}",
                FormatFailure("Expecting be NOT negative:"),
                FormatCurrent(current));

        public static string IsNotZero() =>
            string.Format("{0}\n but is '0'",
                FormatFailure("Expecting be NOT zero:"));

        public static string IsZero(object? current) =>
            string.Format("{0}\n but is {1}",
                FormatFailure("Expecting be zero:"),
                FormatCurrent(current));

        public static string IsIn(object? current, object expected) =>
            string.Format("{0}\n  {1}\n is in\n  {2}",
                FormatFailure("Expecting:"),
                FormatCurrent(current),
                FormatExpected(expected));

        public static string IsNotIn(object? current, object expected) =>
            string.Format("{0}\n  {1}\n is not in\n  {2}",
                FormatFailure("Expecting:"),
                FormatCurrent(current),
                FormatExpected(expected));

        public static string Contains(IEnumerable<object?>? current, IEnumerable<object?> expected, List<object?> notFound) =>
            string.Format("{0}\n  {1}\n do contains (in any order)\n  {2}\n but could not find elements:\n  {3}",
                FormatFailure("Expecting contains elements:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false),
                FormatExpected(notFound, false));

        public static string ContainsExactly(IEnumerable<object?>? current, IEnumerable<object?> expected, List<object?> notFound, List<object?> notExpected)
        {
            if (notExpected.Count == 0 && notFound.Count == 0)
                return string.Format("{0}\n  {1}\n do contains (in same order)\n  {2}\n but has different order {3}",
                    FormatFailure("Expecting contains exactly elements:"),
                    FormatCurrent(current, false),
                    FormatExpected(expected, false),
                    FindFirstDiff(current, expected));

            var message = string.Format("{0}\n  {1}\n do contains (in same order)\n  {2}",
                FormatFailure("Expecting contains exactly elements:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false));
            if (notExpected.Count > 0)
                message += "\n but some elements where not expected:\n  " + FormatExpected(notExpected, false);
            if (notFound.Count > 0)
                message += string.Format("\n {0} could not find elements:\n  {1}", notExpected.Count == 0 ? "but" : "and", FormatExpected(notFound, false));
            return message;
        }

        public static string ContainsExactlyInAnyOrder(IEnumerable<object?>? current, IEnumerable<object?> expected, List<object?> notFound, List<object?> notExpected)
        {
            if (notExpected.Count == 0 && notFound.Count == 0)
                return string.Format("{0}\n  {1}\n do contains (in any order)\n  {2}\n but has different order {3}",
                    FormatFailure("Expecting contains exactly elements:"),
                    FormatCurrent(current, false),
                    FormatExpected(expected, false),
                    FindFirstDiff(current, expected));

            var message = string.Format("{0}\n  {1}\n do contains (in any order)\n  {2}",
                FormatFailure("Expecting contains exactly elements:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false));
            if (notExpected.Count > 0)
                message += "\n but some elements where not expected:\n  " + FormatExpected(notExpected, false);
            if (notFound.Count > 0)
                message += string.Format("\n {0} could not find elements:\n  {1}", notExpected.Count == 0 ? "but" : "and", FormatExpected(notFound, false));
            return message;
        }

        public static string NotContains(string current, string expected) =>
            string.Format("{0}\n  {1}\n do not contain\n  {2}",
                FormatFailure("Expecting:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false));

        public static string NotContainsIgnoringCase(string current, string expected) =>
            string.Format("{0}\n  {1}\n do not contain (ignoring case)\n  {2}",
                FormatFailure("Expecting:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false));

        public static string HasValue(string methodName, object? current, object expected) =>
            string.Format("{0}\n  {1} to be {2} but is {3}",
                FormatFailure("Expecting Property:"),
                FormatCurrent(methodName, false),
                FormatCurrent(expected, false),
                FormatCurrent(current, false));

        public static string Contains(string? current, string expected) =>
            string.Format("{0}\n  {1}\n do contains\n  {2}",
                FormatFailure("Expecting:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false));

        public static string ContainsIgnoringCase(string? current, string expected) =>
            string.Format("{0}\n  {1}\n do contains (ignoring case)\n  {2}",
                FormatFailure("Expecting:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false));

        public static string EndsWith(string? current, string expected) =>
            string.Format("{0}\n  {1}\n to end with\n  {2}",
                FormatFailure("Expecting:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false));

        public static string StartsWith(string? current, string expected) =>
            string.Format("{0}\n  {1}\n to start with\n  {2}",
                FormatFailure("Expecting:"),
                FormatCurrent(current, false),
                FormatExpected(expected, false));

        public static string HasLength(string? current, object currentLength, int expectedLength, IStringAssert.Compare comparator)
        {
            var errorMessage = "";
            switch (comparator)
            {
                case IStringAssert.Compare.EQUAL:
                    errorMessage = "Expecting length:";
                    break;
                case IStringAssert.Compare.LESS_THAN:
                    errorMessage = "Expecting length to be less than:";
                    break;
                case IStringAssert.Compare.LESS_EQUAL:
                    errorMessage = "Expecting length to be less than or equal:";
                    break;
                case IStringAssert.Compare.GREATER_THAN:
                    errorMessage = "Expecting length to be greater than:";
                    break;
                case IStringAssert.Compare.GREATER_EQUAL:
                    errorMessage = "Expecting length to be greater than or equal:";
                    break;
                default:
                    errorMessage = "Invalid comperator";
                    break;
            }
            return string.Format("{0}\n  {1} but is {2}",
                        FormatFailure(errorMessage),
                        FormatExpected(expectedLength),
                        FormatCurrent(currentLength),
                        FormatCurrent(current));
        }


        static string FindFirstDiff(IEnumerable<object?>? left, IEnumerable<object?>? right)
        {
            foreach (var it in left.Select((value, i) => new { Value = value, Index = i }))
            {
                var l = it.Value;
                var r = right?.ElementAt(it.Index);
                if (!Comparable.IsEqual(l, r).Valid)
                    return string.Format("at position {0}\n  {1} vs {2}", FormatCurrent(it.Index), FormatCurrent(l), FormatExpected(r));
            }
            return "";
        }

    }
}
