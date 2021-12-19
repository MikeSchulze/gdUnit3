using System.Diagnostics;
using System.Collections;
using System.Linq;

using static GdUnit3.Assertions;

namespace GdUnit3
{
    public abstract class AssertBase<V> : IAssertBase<V>
    {
        protected readonly Godot.Reference _delegator;
        protected V Current { get; private set; }

        private object CustomFailureMessage { get; set; }

        private EXPECT _expectResult;

        protected int _failureGrapStackLine = 3;

        protected AssertBase(Godot.Reference delegator, V current, EXPECT expectResult = EXPECT.SUCCESS)
        {
            _delegator = delegator;
            Current = current;
            _expectResult = expectResult;
            StackFrame CallStack = new StackFrame(_failureGrapStackLine, true);
            _delegator.Call("set_line_number", CallStack.GetFileLineNumber());
        }

        public IAssertBase<V> IsEqual(V expected)
        {
            var result = Comparable.IsEqual(Current, expected);
            if (!result.Valid)
                return ReportTestFailure(AssertFailures.Equal(Current, expected), Current, expected);
            return this;
        }

        public IAssertBase<V> IsNotEqual(V expected)
        {
            var result = Comparable.IsEqual(Current, expected);
            if (result.Valid)
                return ReportTestFailure(AssertFailures.NotEqual(Current, expected), Current, expected);
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

        public IAssert HasFailureMessage(string expected)
        {
            CallDelegator("has_failure_message", expected);
            return this;
        }

        public IAssert OverrideFailureMessage(string message)
        {
            CustomFailureMessage = message;
            return this;
        }

        public IAssert StartsWithFailureMessage(string message)
        {
            return CallDelegator("starts_with_failure_message", message);
        }

        public IAssert TestFail()
        {
            return CallDelegator("test_fail");
        }

        private void InterruptOnFail()
        {
            if (!IsEnableInterruptOnFailure())
                return;
            var isFailed = (bool)_delegator.Call("is_failed");
            if (isFailed)
            {
                throw new TestFailedException("TestCase interrupted by a failing assert.");
            }
        }

        protected IAssertBase<V> CallDelegator(string methodName, params object[] args)
        {
            _delegator.Call(methodName, args);
            InterruptOnFail();
            return this;
        }

        protected IAssertBase<V> CallDelegator(string methodName, IEnumerable args)
        {
            _delegator.Call(methodName, new Godot.Collections.Array(args.Cast<object>().ToArray()));
            InterruptOnFail();
            return this;
        }

        protected IAssertBase<V> CallDelegator(string methodName, string value)
        {
            _delegator.Call(methodName, value);
            InterruptOnFail();
            return this;
        }

        protected IAssertBase<V> ReportTestFailure(string message, object current, object expected)
        {
            var failureMessage = CustomFailureMessage ?? message;
            _delegator.Call("report_error", failureMessage);
            if (IsEnableInterruptOnFailure())
                throw new TestFailedException("TestCase interuppted by a failing assert.", _failureGrapStackLine);
            return this;
        }
    }
}
