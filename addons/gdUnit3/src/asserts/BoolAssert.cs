namespace GdUnit3.Asserts
{
    internal sealed class BoolAssert : AssertBase<bool>, IBoolAssert
    {

        public BoolAssert(bool current) : base(current)
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
