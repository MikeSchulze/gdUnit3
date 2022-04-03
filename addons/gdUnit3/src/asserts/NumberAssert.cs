using System;

namespace GdUnit3.Asserts
{
    internal class NumberAssert<V> : AssertBase<V>, INumberAssert<V> where V : IComparable
    {
        public NumberAssert(V current) : base(current)
        { }

        public INumberAssert<V> IsBetween(V from, V to)
        {
            if (from.CompareTo(Current) > 0 || Current.CompareTo(to) > 0)
                return ReportTestFailure(AssertFailures.IsBetween(Current, from, to), Current, new V[] { from, to }) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsEven()
        {
            if (Convert.ToInt64(Current) % 2 != 0)
                return ReportTestFailure(AssertFailures.IsEven(Current), Current, null) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsGreater(V expected)
        {
            if (Current.CompareTo(expected) <= 0)
                return ReportTestFailure(AssertFailures.IsGreater(Current, expected), Current, expected) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsGreaterEqual(V expected)
        {
            if (Current.CompareTo(expected) < 0)
                return ReportTestFailure(AssertFailures.IsGreaterEqual(Current, expected), Current, expected) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsIn(params V[] expected)
        {
            if (Array.IndexOf(expected, Current) == -1)
                return ReportTestFailure(AssertFailures.IsIn(Current, expected), Current, expected) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsLess(V expected)
        {
            if (Current.CompareTo(expected) >= 0)
                return ReportTestFailure(AssertFailures.IsLess(Current, expected), Current, expected) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsLessEqual(V expected)
        {
            if (Current.CompareTo(expected) > 0)
                return ReportTestFailure(AssertFailures.IsLessEqual(Current, expected), Current, expected) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsNegative()
        {
            if (Current.CompareTo(0) >= 0)
                return ReportTestFailure(AssertFailures.IsNegative(Current), Current, null) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsNotIn(params V[] expected)
        {
            if (Array.IndexOf(expected, Current) != -1)
                return ReportTestFailure(AssertFailures.IsNotIn(Current, expected), Current, expected) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsNotNegative()
        {
            if (Current.CompareTo(0) < 0)
                return ReportTestFailure(AssertFailures.IsNotNegative(Current), Current, null) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsNotZero()
        {
            if (Convert.ToInt64(Current) == 0)
                return ReportTestFailure(AssertFailures.IsNotZero(), Current, null) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsOdd()
        {
            if (Convert.ToInt64(Current) % 2 == 0)
                return ReportTestFailure(AssertFailures.IsOdd(Current), Current, null) as INumberAssert<V>;
            return this;
        }

        public INumberAssert<V> IsZero()
        {
            if (Convert.ToInt64(Current) != 0)
                return ReportTestFailure(AssertFailures.IsZero(Current), Current, null) as INumberAssert<V>;
            return this;
        }

        public new INumberAssert<V> OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as INumberAssert<V>;
        }
    }
}
