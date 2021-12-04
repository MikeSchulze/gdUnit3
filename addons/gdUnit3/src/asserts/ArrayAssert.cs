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
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult))
        {
            Current = current;
        }

        private IEnumerable Current { get; set; }

        public IArrayAssert IsEqualIgnoringCase(IEnumerable expected)
        {
            _delegator.Call("is_equal_ignoring_case", expected);
            return this;
        }

        public IArrayAssert IsNotEqualIgnoringCase(IEnumerable expected)
        {
            _delegator.Call("is_not_equal_ignoring_case", expected);
            return this;
        }

        public IArrayAssert IsEmpty()
        {
            _delegator.Call("is_empty");
            return this;
        }

        public IArrayAssert IsNotEmpty()
        {
            _delegator.Call("is_not_empty");
            return this;
        }

        public IArrayAssert HasSize(int expected)
        {
            _delegator.Call("has_size", expected);
            return this;
        }

        public IArrayAssert Contains(IEnumerable expected)
        {
            _delegator.Call("contains", expected);
            return this;
        }

        public IArrayAssert ContainsExactly(IEnumerable expected)
        {
            _delegator.Call("contains_exactly", expected);
            return this;
        }

        public IArrayAssert ContainsExactlyInAnyOrder(IEnumerable expected)
        {
            _delegator.Call("contains_exactly_in_any_order", expected);
            return this;
        }

        public IArrayAssert Extract(string funcName, IEnumerable args = null)
        {
            _delegator.Call("extract", funcName, args ?? new Godot.Collections.Array());
            return this;
        }

        public IArrayAssert ExtractV(params IValueExtractor[] extractors)
        {
            var extractedValues = new List<object>();

            foreach (var element in Current)
            {
                object[] values = extractors.Select(e => e.ExtractValue(element)).ToArray<object>();
                extractedValues.Add(values.Count() == 1 ? values.First() : Tuple(values));
            }
            Current = extractedValues;
            _delegator.Call("set_current", Current);
            return this;
        }
    }
}
