using System;

namespace GdUnit3.Asserts
{
    internal sealed class ObjectAssert : AssertBase<object>, IObjectAssert
    {
        public ObjectAssert(object current) : base(current)
        {
            Type type = current?.GetType() ?? null;
            if (type != null && type.IsPrimitive)
                ReportTestFailure(String.Format("ObjectAssert inital error: current is primitive <{0}>", type), Current, null, 1);
        }

        public IObjectAssert IsNotInstanceOf<ExpectedType>()
        {
            if (Current is ExpectedType)
                return ReportTestFailure(AssertFailures.NotInstanceOf(typeof(ExpectedType)), Current, typeof(ExpectedType)) as IObjectAssert;
            return this;
        }

        public IObjectAssert IsNotSame(object expected)
        {
            if (Current == expected)
                return ReportTestFailure(AssertFailures.IsNotSame(expected), Current, expected) as IObjectAssert;
            return this;
        }

        public IObjectAssert IsSame(object expected)
        {
            if (Current != expected)
                return ReportTestFailure(AssertFailures.IsSame(Current, expected), Current, expected) as IObjectAssert;
            return this;
        }

        public IObjectAssert IsInstanceOf<ExpectedType>()
        {
            if (!(Current is ExpectedType))
                return ReportTestFailure(AssertFailures.IsInstanceOf(Current?.GetType() ?? null, typeof(ExpectedType)), Current, typeof(ExpectedType)) as IObjectAssert;
            return this;
        }

        public new IObjectAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IObjectAssert;
        }
    }
}
