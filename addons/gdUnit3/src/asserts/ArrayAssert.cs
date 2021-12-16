using System.Collections;
using System.Collections.Generic;
using System;
using System.Linq;

using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class ArrayAssert : AssertBase<IEnumerable>, IArrayAssert
    {
        private static Godot.GDScript AssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitArrayAssertImpl.gd");

        public ArrayAssert(object caller, IEnumerable current, EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current, expectResult)
        {
            Current = current?.Cast<object>() ?? Enumerable.Empty<object>();
        }

        private new IEnumerable<object> Current { get; set; }

        public IArrayAssert IsEqualIgnoringCase(IEnumerable expected)
        {
            CallDelegator("is_equal_ignoring_case", expected);
            return this;
        }

        public IArrayAssert IsNotEqualIgnoringCase(IEnumerable expected)
        {
            CallDelegator("is_not_equal_ignoring_case", expected);
            return this;
        }

        public IArrayAssert IsEmpty()
        {
            CallDelegator("is_empty");
            return this;
        }

        public IArrayAssert IsNotEmpty()
        {
            CallDelegator("is_not_empty");
            return this;
        }

        public IArrayAssert HasSize(int expected)
        {
            CallDelegator("has_size", expected);
            return this;
        }

        public IArrayAssert Contains(params object[] expected)
        {
            CallDelegator("contains", new Godot.Collections.Array(expected));
            return this;
        }

        public IArrayAssert Contains(IEnumerable expected)
        {
            if (expected.GetEnumerator() is CharEnumerator)
                CallDelegator("contains", new Godot.Collections.Array(new object[] { expected as string }));
            else
                CallDelegator("contains", expected);
            return this;
        }

        public IArrayAssert ContainsExactly(params object[] expected)
        {
            CallDelegator("contains_exactly", new Godot.Collections.Array(expected));
            return this;
        }

        public IArrayAssert ContainsExactly(IEnumerable expected)
        {
            if (expected.GetEnumerator() is CharEnumerator)
                CallDelegator("contains_exactly", new Godot.Collections.Array(new object[] { expected as string }));
            else
                CallDelegator("contains_exactly", expected);
            return this;
        }

        public IArrayAssert ContainsExactlyInAnyOrder(params object[] expected)
        {
            CallDelegator("contains_exactly_in_any_order", new Godot.Collections.Array(expected));
            return this;
        }

        public IArrayAssert ContainsExactlyInAnyOrder(IEnumerable expected)
        {
            if (expected.GetEnumerator() is CharEnumerator)
                CallDelegator("contains_exactly_in_any_order", new Godot.Collections.Array(new object[] { expected as string }));
            else
                CallDelegator("contains_exactly_in_any_order", expected);
            return this;
        }

        public IArrayAssert Extract(string funcName, params object[] args)
        {
            return ExtractV(new ValueExtractor(funcName, args));
        }

        public IArrayAssert ExtractV(params IValueExtractor[] extractors)
        {
            Current = Current.Select(v =>
            {
                object[] values = extractors.Select(e => e.ExtractValue(v)).ToArray<object>();
                return values.Count() == 1 ? values.First() : Tuple(values);
            }).ToList();
            _delegator.Call("set_current", Current);
            return this;
        }


        public new IArrayAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IArrayAssert;
        }
    }
}
