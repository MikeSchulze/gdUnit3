using Godot;

namespace GdUnit3
{
    public sealed class IntAssert : NumberAssert<int>, IIntAssert
    {
        private static Godot.GDScript AssertImpl = GD.Load<GDScript>("res://addons/gdUnit3/src/asserts/GdUnitIntAssertImpl.gd");

        public IntAssert(object caller, object current, IAssert.EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current)
        { }
    }
}
