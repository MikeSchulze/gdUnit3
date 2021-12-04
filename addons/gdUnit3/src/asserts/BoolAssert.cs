using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class BoolAssert : AssertBase<bool>, IBoolAssert
    {
        private static Godot.GDScript GdUnitBoolAssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitBoolAssertImpl.gd");

        public BoolAssert(object caller, object current, EXPECT expectResult)
            : base((Godot.Reference)GdUnitBoolAssertImpl.New(caller, current, expectResult))
        { }

        public IBoolAssert IsFalse()
        {
            _delegator.Call("is_false");
            return this;
        }

        public IBoolAssert IsTrue()
        {
            _delegator.Call("is_true");
            return this;
        }

        public new IBoolAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IBoolAssert;
        }
    }
}
