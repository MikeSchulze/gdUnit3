using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class DoubleAssert : NumberAssert<double>, IDoubleAssert
    {
        private static Godot.GDScript AssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitFloatAssertImpl.gd");
        public DoubleAssert(object caller, double current, EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current)
        { }
    }
}
