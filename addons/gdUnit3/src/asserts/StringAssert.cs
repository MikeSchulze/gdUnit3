namespace GdUnit3.Asserts
{
    internal sealed class StringAssert : AssertBase<string>, IStringAssert
    {
        public StringAssert(string current) : base(current)
        { }

        public IStringAssert Contains(string expected)
        {
            if (Current == null || !(Current as string).Contains(expected))
                return ReportTestFailure(AssertFailures.Contains(Current, expected), Current, expected) as IStringAssert;
            return this;
        }

        public IStringAssert ContainsIgnoringCase(string expected)
        {
            if (Current == null || !(Current as string).ToLower().Contains(expected.ToLower()))
                return ReportTestFailure(AssertFailures.ContainsIgnoringCase(Current, expected), Current, expected) as IStringAssert;
            return this;
        }

        public IStringAssert EndsWith(string expected)
        {
            if (Current == null || !(Current as string).EndsWith(expected))
                return ReportTestFailure(AssertFailures.EndsWith(Current, expected), Current, expected) as IStringAssert;
            return this;
        }

        public IStringAssert HasLength(int expectedLenght, IStringAssert.Compare comparator = IStringAssert.Compare.EQUAL)
        {
            var currentLenght = (Current as string)?.Length ?? null;
            var failed = false;
            switch (comparator)
            {
                case IStringAssert.Compare.EQUAL:
                    if (currentLenght == null || currentLenght != expectedLenght)
                        failed = true;
                    break;
                case IStringAssert.Compare.GREATER_EQUAL:
                    if (currentLenght == null || currentLenght < expectedLenght)
                        failed = true;
                    break;
                case IStringAssert.Compare.GREATER_THAN:
                    if (currentLenght == null || currentLenght <= expectedLenght)
                        failed = true;
                    break;
                case IStringAssert.Compare.LESS_EQUAL:
                    if (currentLenght == null || currentLenght > expectedLenght)
                        failed = true;
                    break;
                case IStringAssert.Compare.LESS_THAN:
                    if (currentLenght == null || currentLenght >= expectedLenght)
                        failed = true;
                    break;
            }
            if (failed)
                return ReportTestFailure(AssertFailures.HasLength(Current, currentLenght, expectedLenght, comparator), Current, expectedLenght) as IStringAssert;
            return this;
        }

        public IStringAssert IsEmpty()
        {
            if (Current == null || (Current as string).Length > 0)
                return ReportTestFailure(AssertFailures.IsEmpty(Current), Current, null) as IStringAssert;
            return this;
        }

        public IStringAssert IsEqualIgnoringCase(string expected)
        {
            var result = Comparable.IsEqual(Current, expected, Comparable.MODE.CASE_INSENSITIVE);
            if (!result.Valid)
                return ReportTestFailure(AssertFailures.IsEqualIgnoringCase(Current, expected), Current, expected) as IStringAssert;
            return this;
        }

        public IStringAssert IsNotEmpty()
        {
            if (Current != null && (Current as string).Length == 0)
                return ReportTestFailure(AssertFailures.IsNotEmpty(), Current, null) as IStringAssert;
            return this;
        }

        public IStringAssert IsNotEqualIgnoringCase(string expected)
        {
            var result = Comparable.IsEqual(Current, expected, Comparable.MODE.CASE_INSENSITIVE);
            if (result.Valid)
                return ReportTestFailure(AssertFailures.IsNotEqualIgnoringCase(Current, expected), Current, expected) as IStringAssert;
            return this;
        }

        public IStringAssert NotContains(string expected)
        {
            if (Current != null && (Current as string).Contains(expected))
                return ReportTestFailure(AssertFailures.NotContains(Current, expected), Current, expected) as IStringAssert;
            return this;
        }

        public IStringAssert NotContainsIgnoringCase(string expected)
        {
            if (Current != null && (Current as string).ToLower().Contains(expected.ToLower()))
                return ReportTestFailure(AssertFailures.NotContainsIgnoringCase(Current, expected), Current, expected) as IStringAssert;
            return this;
        }

        public IStringAssert StartsWith(string expected)
        {
            if (Current == null || !(Current as string).StartsWith(expected))
                return ReportTestFailure(AssertFailures.StartsWith(Current, expected), Current, expected) as IStringAssert;
            return this;
        }

        public new IStringAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IStringAssert;
        }
    }
}
