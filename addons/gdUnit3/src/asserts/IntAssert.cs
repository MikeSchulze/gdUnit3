using System;

using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class IntAssert : NumberAssert<int>, IIntAssert
    {
        private static Godot.GDScript AssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitIntAssertImpl.gd");

        public IntAssert(object caller, int current, EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current)
        { }
    }
}
