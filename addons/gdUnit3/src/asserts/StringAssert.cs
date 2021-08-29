using Godot;

namespace GdUnit3
{
    public sealed class StringAssert : AssertBase<string>, IStringAssert
    {
        private static Godot.GDScript AssertImpl = GD.Load<GDScript>("res://addons/gdUnit3/src/asserts/GdUnitStringAssertImpl.gd");

        public StringAssert(object caller, object current, IAssert.EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult))
        { }

        public IStringAssert Contains(string expected)
        {
            _delegator.Call("contains", expected);
            return this;
        }

        public IStringAssert ContainsIgnoringCase(string expected)
        {
            _delegator.Call("contains_ignoring_case", expected);
            return this;
        }

        public IStringAssert EndsWith(string expected)
        {
            _delegator.Call("ends_with", expected);
            return this;
        }

        public IStringAssert HasLength(int lenght, IStringAssert.Compare comparator = IStringAssert.Compare.EQUAL)
        {
            _delegator.Call("has_length", lenght, comparator);
            return this;
        }

        public IStringAssert IsEmpty()
        {
            _delegator.Call("is_empty");
            return this;
        }

        public IStringAssert IsEqualIgnoringCase(string expected)
        {
            _delegator.Call("is_equal_ignoring_case", expected);
            return this;
        }

        public IStringAssert IsNotEmpty()
        {
            _delegator.Call("is_not_empty");
            return this;
        }

        public IStringAssert IsNotEqualIgnoringCase(string expected)
        {
            _delegator.Call("is_not_equal_ignoring_case", expected);
            return this;
        }

        public IStringAssert NotContains(string expected)
        {
            _delegator.Call("not_contains", expected);
            return this;
        }

        public IStringAssert NotContainsIgnoringCase(string expected)
        {
            _delegator.Call("not_contains_ignoring_case", expected);
            return this;
        }

        public IStringAssert StartsWith(string expected)
        {
            _delegator.Call("starts_with", expected);
            return this;
        }

    }
}
