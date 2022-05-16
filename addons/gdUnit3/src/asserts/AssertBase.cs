namespace GdUnit3.Asserts
{
    using Exceptions;

    internal abstract class AssertBase<V> : IAssertBase<V>
    {
        protected V? Current { get; private set; }

        private string? CustomFailureMessage { get; set; } = null;

        private string CurrentFailureMessage { get; set; } = "";

        protected AssertBase(V? current)
        {
            Current = current;
        }

        public IAssertBase<V> IsEqual(V expected)
        {
            var result = Comparable.IsEqual(Current, expected);
            if (!result.Valid)
                ThrowTestFailureReport(AssertFailures.IsEqual(Current, expected), Current, expected);
            return this;
        }

        public IAssertBase<V> IsNotEqual(V expected)
        {
            var result = Comparable.IsEqual(Current, expected);
            if (result.Valid)
                ThrowTestFailureReport(AssertFailures.IsNotEqual(Current, expected), Current, expected);
            return this;
        }
        public IAssertBase<V> IsNull()
        {
            if (Current != null)
                ThrowTestFailureReport(AssertFailures.IsNull(Current), Current, null);
            return this;
        }

        public IAssertBase<V> IsNotNull()
        {
            if (Current == null)
                ThrowTestFailureReport(AssertFailures.IsNotNull(Current), Current, null);
            return this;
        }

        public IAssert HasFailureMessage(string message)
        {
            var current = NormalizedFailureMessage(CurrentFailureMessage);
            if (!current.Equals(message))
                ThrowTestFailureReport(AssertFailures.IsEqual(current, message), current, message);
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
                ThrowTestFailureReport(AssertFailures.IsEqual(current, message), current, message);
            return this;
        }

        private static string NormalizedFailureMessage(string? input)
        {
            using (var rtl = new Godot.RichTextLabel())
            {
                rtl.BbcodeEnabled = true;
                rtl.ParseBbcode(input);
                rtl.QueueFree();
                return rtl.Text;
            }
        }

        protected void ThrowTestFailureReport(string message, object? current, object? expected, int stackFrameOffset = 0)
        {
            var failureMessage = CustomFailureMessage ?? message;
            CurrentFailureMessage = failureMessage;
            throw new TestFailedException(failureMessage, stackFrameOffset);
        }
    }
}
