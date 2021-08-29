using System;

namespace GdUnit3
{
    public class NumberAssert<V> : AssertBase<V>, INumberAssert<V>
    {
        public NumberAssert(Godot.Reference delegator, object current) : base(delegator, current)
        { }

        public INumberAssert<V> IsBetween(V from, V to)
        {
            _delegator.Call("is_between", from, to);
            return this;
        }

        public INumberAssert<V> IsEven()
        {
            _delegator.Call("is_even");
            return this;
        }

        public INumberAssert<V> IsGreater(V expected)
        {
            _delegator.Call("is_greater", expected);
            return this;
        }

        public INumberAssert<V> IsGreaterEqual(V expected)
        {
            _delegator.Call("is_greater_equal", expected);
            return this;
        }

        public INumberAssert<V> IsIn(Array expected)
        {
            _delegator.Call("is_in", expected);
            return this;
        }

        public INumberAssert<V> IsLess(V expected)
        {
            _delegator.Call("is_less", expected);
            return this;
        }

        public INumberAssert<V> IsLessEqual(V expected)
        {
            _delegator.Call("is_less_equal", expected);
            return this;
        }

        public INumberAssert<V> IsNegative()
        {
            _delegator.Call("is_negative");
            return this;
        }

        public INumberAssert<V> IsNotIn(Array expected)
        {
            _delegator.Call("is_not_in", expected);
            return this;
        }

        public INumberAssert<V> IsNotNegative()
        {
            _delegator.Call("is_not_negative");
            return this;
        }

        public INumberAssert<V> IsNotZero()
        {
            _delegator.Call("is_not_zero");
            return this;
        }

        public INumberAssert<V> IsOdd()
        {
            _delegator.Call("is_odd");
            return this;
        }

        public INumberAssert<V> IsZero()
        {
            _delegator.Call("is_zero");
            return this;
        }
    }
}
