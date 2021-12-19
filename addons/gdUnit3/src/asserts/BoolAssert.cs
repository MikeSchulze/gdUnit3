using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class BoolAssert : AssertBase<bool>, IBoolAssert
    {
        private static Godot.GDScript GdUnitBoolAssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitBoolAssertImpl.gd");

        public BoolAssert(object caller, bool current, EXPECT expectResult)
            : base((Godot.Reference)GdUnitBoolAssertImpl.New(caller, current, expectResult), current)
        { }

        public IBoolAssert IsFalse()
        {
            if (true.Equals(Current))
                return ReportTestFailure(AssertFailures.IsFalse(), Current, false) as IBoolAssert;
            return this;
        }

        public IBoolAssert IsTrue()
        {
            if (!true.Equals(Current))
                return ReportTestFailure(AssertFailures.IsTrue(), Current, true) as IBoolAssert;
            return this;
        }

        public new IBoolAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IBoolAssert;
        }
    }
}
