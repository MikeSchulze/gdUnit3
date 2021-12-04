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
            return CallDelegator<ArrayAssert>("is_equal_ignoring_case", expected);
        }

        public IArrayAssert IsNotEqualIgnoringCase(IEnumerable expected)
        {
            return CallDelegator<ArrayAssert>("is_not_equal_ignoring_case", expected);
        }

        public IArrayAssert IsEmpty()
        {
            return CallDelegator<ArrayAssert>("is_empty");
        }

        public IArrayAssert IsNotEmpty()
        {
            return CallDelegator<ArrayAssert>("is_not_empty");
        }

        public IArrayAssert HasSize(int expected)
        {
            return CallDelegator<ArrayAssert>("has_size", expected);
        }

        public IArrayAssert Contains(IEnumerable expected)
        {
            return CallDelegator<ArrayAssert>("contains", expected);
        }

        public IArrayAssert ContainsExactly(IEnumerable expected)
        {
            return CallDelegator<ArrayAssert>("contains_exactly", expected);
        }

        public IArrayAssert ContainsExactlyInAnyOrder(IEnumerable expected)
        {
            return CallDelegator<ArrayAssert>("contains_exactly_in_any_order", expected);
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
            return CallDelegator<ArrayAssert>("set_current", Current);
        }
    }
}
