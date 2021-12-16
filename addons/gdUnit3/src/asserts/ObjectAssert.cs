using System;

using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class ObjectAssert : AssertBase<object>, IObjectAssert
    {
        private static Godot.GDScript AssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitObjectAssertImpl.gd");

        public ObjectAssert(object caller, object current, EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current)
        { }

        public IObjectAssert IsNotInstanceOf<ExpectedType>()
        {
            if (Current is ExpectedType)
            {
                var message = String.Format("Expected not be a instance of <{0}>", typeof(ExpectedType));
                _delegator.Call("report_error", message);
                if (IsEnableInterruptOnFailure())
                    throw new TestFailedException("TestCase interuppted by a failing assert.", 2);
                return this;
            }
            _delegator.Call("report_success");
            return this;
        }

        public IObjectAssert IsNotSame(object expected)
        {
            CallDelegator("is_not_same", expected);
            return this;
        }

        public IObjectAssert IsSame(object expected)
        {
            CallDelegator("is_same", expected);
            return this;
        }

        public IObjectAssert IsInstanceOf<ExpectedType>()
        {
            if (!(Current is ExpectedType))
            {
                var message = AssertFailures.ErrorIsInstanceOf(Current?.GetType() ?? null, typeof(ExpectedType));
                _delegator.Call("report_error", message);
                if (IsEnableInterruptOnFailure())
                    throw new TestFailedException("TestCase interuppted by a failing assert.", 2);
                return this;
            }
            _delegator.Call("report_success");
            return this;
        }

        public new IObjectAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IObjectAssert;
        }
    }
}
