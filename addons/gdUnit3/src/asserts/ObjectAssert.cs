
using System;
using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class ObjectAssert : AssertBase<object>, IObjectAssert
    {
        private static Godot.GDScript AssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitObjectAssertImpl.gd");

        public ObjectAssert(object caller, object current, EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, null, expectResult), current)
        {
            Type type = current?.GetType() ?? null;
            if (type != null && type.IsPrimitive)
                ReportTestFailure(String.Format("ObjectAssert inital error: current is primitive <{0}>", type), Current, null);
        }

        public IObjectAssert IsNotInstanceOf<ExpectedType>()
        {
            if (Current is ExpectedType)
                return ReportTestFailure(AssertFailures.NotInstanceOf(typeof(ExpectedType)), Current, typeof(ExpectedType)) as IObjectAssert;
            _delegator.Call("report_success");
            return this;
        }

        public IObjectAssert IsNotSame(object expected)
        {
            if (Current == expected)
                return ReportTestFailure(AssertFailures.IsNotSame(expected), Current, expected) as IObjectAssert;
            _delegator.Call("report_success");
            return this;
        }

        public IObjectAssert IsSame(object expected)
        {
            if (Current != expected)
                return ReportTestFailure(AssertFailures.IsSame(Current, expected), Current, expected) as IObjectAssert;
            _delegator.Call("report_success");
            return this;
        }

        public IObjectAssert IsInstanceOf<ExpectedType>()
        {
            if (!(Current is ExpectedType))
                return ReportTestFailure(AssertFailures.IsInstanceOf(Current?.GetType() ?? null, typeof(ExpectedType)), Current, typeof(ExpectedType)) as IObjectAssert;
            _delegator.Call("report_success");
            return this;
        }

        public new IObjectAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IObjectAssert;
        }
    }
}
