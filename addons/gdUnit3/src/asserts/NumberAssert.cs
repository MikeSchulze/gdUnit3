using System;

namespace GdUnit3
{
    public class NumberAssert<V> : AssertBase<V>, INumberAssert<V>
    {
        public NumberAssert(Godot.Reference delegator, object current) : base(delegator, current)
        { }

        public INumberAssert<V> IsBetween(V from, V to)
        {
            CallDelegator("is_between", from, to);
            return this;
        }

        public INumberAssert<V> IsEven()
        {
            CallDelegator("is_even");
            return this;
        }

        public INumberAssert<V> IsGreater(V expected)
        {
            CallDelegator("is_greater", expected);
            return this;
        }

        public INumberAssert<V> IsGreaterEqual(V expected)
        {
            CallDelegator("is_greater_equal", expected);
            return this;
        }

        public INumberAssert<V> IsIn(Array expected)
        {
            CallDelegator("is_in", expected);
            return this;
        }

        public INumberAssert<V> IsLess(V expected)
        {
            CallDelegator("is_less", expected);
            return this;
        }

        public INumberAssert<V> IsLessEqual(V expected)
        {
            CallDelegator("is_less_equal", expected);
            return this;
        }

        public INumberAssert<V> IsNegative()
        {
            CallDelegator("is_negative");
            return this;
        }

        public INumberAssert<V> IsNotIn(Array expected)
        {
            CallDelegator("is_not_in", expected);
            return this;
        }

        public INumberAssert<V> IsNotNegative()
        {
            CallDelegator("is_not_negative");
            return this;
        }

        public INumberAssert<V> IsNotZero()
        {
            CallDelegator("is_not_zero");
            return this;
        }

        public INumberAssert<V> IsOdd()
        {
            CallDelegator("is_odd");
            return this;
        }

        public INumberAssert<V> IsZero()
        {
            CallDelegator("is_zero");
            return this;
        }

        public new INumberAssert<V> OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as INumberAssert<V>;
        }
    }
}
