using System;

namespace GdUnit3.Asserts
{
    internal sealed class ObjectAssert : AssertBase<object>, IObjectAssert
    {
        public ObjectAssert(object? current) : base(current)
        {
            Type? type = current?.GetType();
            if (type != null && type.IsPrimitive)
                ThrowTestFailureReport(String.Format("ObjectAssert inital error: current is primitive <{0}>", type), Current, null, 1);
        }

        public IObjectAssert IsNotInstanceOf<ExpectedType>()
        {
            if (Current is ExpectedType)
                ThrowTestFailureReport(AssertFailures.NotInstanceOf(typeof(ExpectedType)), Current, typeof(ExpectedType));
            return this;
        }

        public IObjectAssert IsNotSame(object expected)
        {
            if (Current == expected)
                ThrowTestFailureReport(AssertFailures.IsNotSame(expected), Current, expected);
            return this;
        }

        public IObjectAssert IsSame(object expected)
        {
            if (Current != expected)
                ThrowTestFailureReport(AssertFailures.IsSame(Current, expected), Current, expected);
            return this;
        }

        public IObjectAssert IsInstanceOf<ExpectedType>()
        {
            if (!(Current is ExpectedType))
                ThrowTestFailureReport(AssertFailures.IsInstanceOf(Current?.GetType(), typeof(ExpectedType)), Current, typeof(ExpectedType));
            return this;
        }

        public new IObjectAssert OverrideFailureMessage(string message)
        {
            base.OverrideFailureMessage(message);
            return this;
        }
    }
}
