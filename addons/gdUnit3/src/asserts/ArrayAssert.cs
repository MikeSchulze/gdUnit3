using System.Collections;
using System.Collections.Generic;
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

        private IEnumerable<object> Current { get; set; }

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

        public IArrayAssert Contains(IEnumerable expected)
        {
            CallDelegator("contains", expected);
            return this;
        }

        public IArrayAssert ContainsExactly(IEnumerable expected)
        {
            CallDelegator("contains_exactly", expected);
            return this;
        }

        public IArrayAssert ContainsExactlyInAnyOrder(IEnumerable expected)
        {
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
            CallDelegator("set_current", Current);
            return this;
        }


        public new IArrayAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IArrayAssert;
        }
    }
}
