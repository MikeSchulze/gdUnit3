using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class StringAssert : AssertBase<string>, IStringAssert
    {
        private static Godot.GDScript AssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitStringAssertImpl.gd");

        public StringAssert(object caller, object current, EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current)
        { }

        public IStringAssert Contains(string expected)
        {
            CallDelegator("contains", expected);
            return this;
        }

        public IStringAssert ContainsIgnoringCase(string expected)
        {
            CallDelegator("contains_ignoring_case", expected);
            return this;
        }

        public IStringAssert EndsWith(string expected)
        {
            CallDelegator("ends_with", expected);
            return this;
        }

        public IStringAssert HasLength(int lenght, IStringAssert.Compare comparator = IStringAssert.Compare.EQUAL)
        {
            CallDelegator("has_length", lenght, comparator);
            return this;
        }

        public IStringAssert IsEmpty()
        {
            CallDelegator("is_empty");
            return this;
        }

        public IStringAssert IsEqualIgnoringCase(string expected)
        {
            CallDelegator("is_equal_ignoring_case", expected);
            return this;
        }

        public IStringAssert IsNotEmpty()
        {
            CallDelegator("is_not_empty");
            return this;
        }

        public IStringAssert IsNotEqualIgnoringCase(string expected)
        {
            CallDelegator("is_not_equal_ignoring_case", expected);
            return this;
        }

        public IStringAssert NotContains(string expected)
        {
            CallDelegator("not_contains", expected);
            return this;
        }

        public IStringAssert NotContainsIgnoringCase(string expected)
        {
            CallDelegator("not_contains_ignoring_case", expected);
            return this;
        }

        public IStringAssert StartsWith(string expected)
        {
            CallDelegator("starts_with", expected);
            return this;
        }

        public new IStringAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IStringAssert;
        }
    }
}
