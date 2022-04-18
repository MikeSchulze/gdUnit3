namespace GdUnit3.Asserts
{
    using Exceptions;

    internal abstract class AssertBase<V> : IAssertBase<V>
    {
        protected V Current { get; private set; }

        private string CustomFailureMessage { get; set; }

        private string CurrentFailureMessage { get; set; }

        protected AssertBase(V current)
        {
            Current = current;
            CurrentFailureMessage = null;
        }

        public IAssertBase<V> IsEqual(V expected)
        {
            var result = Comparable.IsEqual(Current, expected);
            if (!result.Valid)
                return ReportTestFailure(AssertFailures.IsEqual(Current, expected), Current, expected);
            return this;
        }

        public IAssertBase<V> IsNotEqual(V expected)
        {
            var result = Comparable.IsEqual(Current, expected);
            if (result.Valid)
                return ReportTestFailure(AssertFailures.IsNotEqual(Current, expected), Current, expected);
            return this;
        }
        public IAssertBase<V> IsNull()
        {
            if (Current != null)
                return ReportTestFailure(AssertFailures.IsNull(Current), Current, null);
            return this;
        }

        public IAssertBase<V> IsNotNull()
        {
            if (Current == null)
                return ReportTestFailure(AssertFailures.IsNotNull(Current), Current, null);
            return this;
        }

        public IAssert HasFailureMessage(string message)
        {
            var current = NormalizedFailureMessage(CurrentFailureMessage);
            if (!current.Equals(message))
                return ReportTestFailure(AssertFailures.IsEqual(current, message), current, message);
            return this;
        }

        public IAssert OverrideFailureMessage(string message)
        {
            CustomFailureMessage = message;
            return this;
        }

        public IAssert StartsWithFailureMessage(string message)
        {
            var current = NormalizedFailureMessage(CurrentFailureMessage);
            if (!current.StartsWith(message))
                return ReportTestFailure(AssertFailures.IsEqual(current, message), current, message);
            return this;
        }

        private static string NormalizedFailureMessage(string input)
        {
            using (var rtl = new Godot.RichTextLabel())
            {
                rtl.BbcodeEnabled = true;
                rtl.ParseBbcode(input);
                rtl.QueueFree();
                return rtl.Text;
            }
        }

        protected IAssertBase<V> ReportTestFailure(string message, object current, object expected, int stackFrameOffset = 0)
        {
            var failureMessage = CustomFailureMessage ?? message;
            CurrentFailureMessage = failureMessage;
            throw new TestFailedException(failureMessage, stackFrameOffset);
        }
    }
}
