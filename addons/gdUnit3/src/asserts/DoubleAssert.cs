using Godot;

namespace GdUnit3
{
    public sealed class DoubleAssert : NumberAssert<double>, IDoubleAssert
    {
        private static Godot.GDScript AssertImpl = GD.Load<GDScript>("res://addons/gdUnit3/src/asserts/GdUnitFloatAssertImpl.gd");
        public DoubleAssert(object caller, object current, IAssert.EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current)
        {
        }
    }
}
