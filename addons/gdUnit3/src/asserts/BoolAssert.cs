using Godot;

namespace GdUnit3
{
    public sealed class BoolAssert : AssertBase<bool>, IBoolAssert
    {
        private static Godot.GDScript GdUnitBoolAssertImpl = GD.Load<GDScript>("res://addons/gdUnit3/src/asserts/GdUnitBoolAssertImpl.gd");

        public BoolAssert(object caller, object current, IAssert.EXPECT expectResult)
            : base((Godot.Reference)GdUnitBoolAssertImpl.New(caller, current, expectResult))
        {

        }

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

    }
}
