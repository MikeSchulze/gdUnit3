namespace GdUnit3.Asserts
{
    internal sealed class StringAssert : AssertBase<string>, IStringAssert
    {
        public StringAssert(string? current) : base(current)
        { }

        public IStringAssert Contains(string expected)
        {
            if (Current == null || !(Current as string).Contains(expected))
                ThrowTestFailureReport(AssertFailures.Contains(Current, expected), Current, expected);
            return this;
        }

        public IStringAssert ContainsIgnoringCase(string expected)
        {
            if (Current == null || !(Current as string).ToLower().Contains(expected.ToLower()))
                ThrowTestFailureReport(AssertFailures.ContainsIgnoringCase(Current, expected), Current, expected);
            return this;
        }

        public IStringAssert EndsWith(string expected)
        {
            if (Current == null || !(Current as string).EndsWith(expected))
                ThrowTestFailureReport(AssertFailures.EndsWith(Current, expected), Current, expected);
            return this;
        }

        public IStringAssert HasLength(int expectedLenght, IStringAssert.Compare comparator = IStringAssert.Compare.EQUAL)
        {
            if (Current == null)
                ThrowTestFailureReport(AssertFailures.HasLength(Current, "unknown", expectedLenght, comparator), Current, expectedLenght);

            int currentLenght = (Current as string)?.Length ?? -1;
            var failed = false;
            switch (comparator)
            {
                case IStringAssert.Compare.EQUAL:
                    if (currentLenght != expectedLenght)
                        failed = true;
                    break;
                case IStringAssert.Compare.GREATER_EQUAL:
                    if (currentLenght < expectedLenght)
                        failed = true;
                    break;
                case IStringAssert.Compare.GREATER_THAN:
                    if (currentLenght <= expectedLenght)
                        failed = true;
                    break;
                case IStringAssert.Compare.LESS_EQUAL:
                    if (currentLenght > expectedLenght)
                        failed = true;
                    break;
                case IStringAssert.Compare.LESS_THAN:
                    if (currentLenght >= expectedLenght)
                        failed = true;
                    break;
            }
            if (failed)
                ThrowTestFailureReport(AssertFailures.HasLength(Current, currentLenght, expectedLenght, comparator), Current, expectedLenght);
            return this;
        }

        public IStringAssert IsEmpty()
        {
            if (Current == null || (Current as string).Length > 0)
                ThrowTestFailureReport(AssertFailures.IsEmpty(Current), Current, null);
            return this;
        }

        public IStringAssert IsEqualIgnoringCase(string expected)
        {
            var result = Comparable.IsEqual(Current, expected, Comparable.MODE.CASE_INSENSITIVE);
            if (!result.Valid)
                ThrowTestFailureReport(AssertFailures.IsEqualIgnoringCase(Current, expected), Current, expected);
            return this;
        }

        public IStringAssert IsNotEmpty()
        {
            if (Current != null && (Current as string).Length == 0)
                ThrowTestFailureReport(AssertFailures.IsNotEmpty(), Current, null);
            return this;
        }

        public IStringAssert IsNotEqualIgnoringCase(string expected)
        {
            var result = Comparable.IsEqual(Current, expected, Comparable.MODE.CASE_INSENSITIVE);
            if (result.Valid)
                ThrowTestFailureReport(AssertFailures.IsNotEqualIgnoringCase(Current, expected), Current, expected);
            return this;
        }

        public IStringAssert NotContains(string expected)
        {
            if (Current != null && (Current as string).Contains(expected))
                ThrowTestFailureReport(AssertFailures.NotContains(Current, expected), Current, expected);
            return this;
        }

        public IStringAssert NotContainsIgnoringCase(string expected)
        {
            if (Current != null && (Current as string).ToLower().Contains(expected.ToLower()))
                ThrowTestFailureReport(AssertFailures.NotContainsIgnoringCase(Current, expected), Current, expected);
            return this;
        }

        public IStringAssert StartsWith(string expected)
        {
            if (Current == null || !(Current as string).StartsWith(expected))
                ThrowTestFailureReport(AssertFailures.StartsWith(Current, expected), Current, expected);
            return this;
        }

        public new IStringAssert OverrideFailureMessage(string message)
        {
            base.OverrideFailureMessage(message);
            return this;
        }
    }
}
