using System;

namespace GdUnit3.Asserts
{
    internal class NumberAssert<V> : AssertBase<V>, INumberAssert<V> where V : IComparable
    {
        public NumberAssert(V current) : base(current)
        { }

        public INumberAssert<V> IsBetween(V from, V to)
        {
            if (from.CompareTo(Current) > 0 || Current?.CompareTo(to) > 0)
                ThrowTestFailureReport(AssertFailures.IsBetween(Current, from, to), Current, new V[] { from, to });
            return this;
        }

        public INumberAssert<V> IsEven()
        {
            if (Convert.ToInt64(Current) % 2 != 0)
                ThrowTestFailureReport(AssertFailures.IsEven(Current), Current, null);
            return this;
        }

        public INumberAssert<V> IsGreater(V expected)
        {
            if (Current?.CompareTo(expected) <= 0)
                ThrowTestFailureReport(AssertFailures.IsGreater(Current, expected), Current, expected);
            return this;
        }

        public INumberAssert<V> IsGreaterEqual(V expected)
        {
            if (Current?.CompareTo(expected) < 0)
                ThrowTestFailureReport(AssertFailures.IsGreaterEqual(Current, expected), Current, expected);
            return this;
        }

        public INumberAssert<V> IsIn(params V[] expected)
        {
            if (Array.IndexOf(expected, Current) == -1)
                ThrowTestFailureReport(AssertFailures.IsIn(Current, expected), Current, expected);
            return this;
        }

        public INumberAssert<V> IsLess(V expected)
        {
            if (Current?.CompareTo(expected) >= 0)
                ThrowTestFailureReport(AssertFailures.IsLess(Current, expected), Current, expected);
            return this;
        }

        public INumberAssert<V> IsLessEqual(V expected)
        {
            if (Current?.CompareTo(expected) > 0)
                ThrowTestFailureReport(AssertFailures.IsLessEqual(Current, expected), Current, expected);
            return this;
        }

        public INumberAssert<V> IsNegative()
        {
            if (Current?.CompareTo(0) >= 0)
                ThrowTestFailureReport(AssertFailures.IsNegative(Current), Current, null);
            return this;
        }

        public INumberAssert<V> IsNotIn(params V[] expected)
        {
            if (Array.IndexOf(expected, Current) != -1)
                ThrowTestFailureReport(AssertFailures.IsNotIn(Current, expected), Current, expected);
            return this;
        }

        public INumberAssert<V> IsNotNegative()
        {
            if (Current?.CompareTo(0) < 0)
                ThrowTestFailureReport(AssertFailures.IsNotNegative(Current), Current, null);
            return this;
        }

        public INumberAssert<V> IsNotZero()
        {
            if (Convert.ToInt64(Current) == 0)
                ThrowTestFailureReport(AssertFailures.IsNotZero(), Current, null);
            return this;
        }

        public INumberAssert<V> IsOdd()
        {
            if (Convert.ToInt64(Current) % 2 == 0)
                ThrowTestFailureReport(AssertFailures.IsOdd(Current), Current, null);
            return this;
        }

        public INumberAssert<V> IsZero()
        {
            if (Convert.ToInt64(Current) != 0)
                ThrowTestFailureReport(AssertFailures.IsZero(Current), Current, null);
            return this;
        }

        public new INumberAssert<V> OverrideFailureMessage(string message)
        {
            base.OverrideFailureMessage(message);
            return this;
        }
    }
}
