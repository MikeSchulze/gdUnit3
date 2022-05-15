using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;

namespace GdUnit3
{
    internal sealed class Comparable
    {
        public enum MODE
        {
            CASE_SENSITIVE,
            CASE_INSENSITIVE
        }

        public class Result
        {
            public static Result Equal => new Result(true, null, null);

            public Result(bool valid, object? left, object? right, Result? parent = null)
            {
                Valid = valid;
                Left = left;
                Right = right;
                Parent = parent;
            }

            public Result WithProperty(string propertyName)
            {
                PropertyName = propertyName;
                return this;
            }

            private object? Left { get; set; }

            private object? Right { get; set; }

            private string? PropertyName { get; set; }

            private Result? Parent
            { get; set; }

            public bool Valid
            { get; private set; }
        }

        private static List<Type> Excludes = new List<Type>() {
            typeof(IntPtr),
            typeof(Godot.DynamicGodotObject)
        };

        public static Result IsEqual<T>(T? left, T? right, MODE compareMode = MODE.CASE_SENSITIVE, Result? r = null)
        {
            //Godot.GD.PrintS(typeof(T), left, right);
            if (left == null && right == null)
                return Result.Equal;

            if (left == null || right == null)
                return new Result(false, left, right);

            if (object.ReferenceEquals(left, right))
                return new Result(true, left, right, r);

            var type = left.GetType();
            if (type.IsEnum)
                return new Result(left.Equals(right), left, right, r);

            if (type.IsPrimitive || typeof(string).Equals(type) || left is IEquatable<T> || left is System.ValueType)
            {
                //Godot.GD.PrintS("IsPrimitive", type, left, right);
                if (left is String && compareMode == MODE.CASE_INSENSITIVE)
                    return new Result(left.ToString().ToLower().Equals(right.ToString().ToLower()), left, right, r);
                return new Result(left.Equals(right), left, right, r);
            }

            if (type.IsArray)
            {
                var la = left as Array;
                var ra = right as Array;
                if (la?.Length != ra?.Length)
                    return new Result(false, left, right, r);
                for (int index = 0; index < la?.Length; index++)
                {
                    var result = IsEqual(la.GetValue(index), ra?.GetValue(index), compareMode);
                    if (!result.Valid)
                        return result;
                }
                return new Result(true, left, right, r);
            }

            if (left is IEnumerable)
            {
                var itLeft = ((IEnumerable)left).GetEnumerator();
                var itRight = ((IEnumerable)right).GetEnumerator();

                while (true)
                {
                    bool lnext = itLeft.MoveNext();
                    bool rnext = itRight.MoveNext();
                    if (!lnext && !rnext) // Both sequences finished
                        break;
                    // has different size
                    if (lnext != rnext)
                    {
                        return new Result(false, left, right, r);
                    }
                    var result = IsEqual(itLeft.Current, itRight.Current, compareMode);
                    if (!result.Valid)
                        return result;
                }
                return new Result(true, left, right, r);
            }

            if (!left.GetType().Equals(right.GetType()))
                return new Result(false, left, right, r);


            // deep compare
            foreach (var property in type.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
            {
                //Godot.GD.PrintS(property.Name, property.PropertyType);
                var lv = property.GetValue(left, null);
                var rv = property.GetValue(right, null);
                if (lv != null && Excludes.Contains(lv.GetType()))
                    continue;

                // to invoke could be a performance issue
                var IsEqualMethod = typeof(Comparable).GetMethod("IsEqual").MakeGenericMethod(property.PropertyType);
                Result result = (Result)IsEqualMethod.Invoke(null, new object?[] { lv, rv, compareMode, r });
                if (!result.Valid)
                {
                    return result.WithProperty(property.Name);
                }
            }
            return new Result(true, left, right, r);
        }
    }
}
