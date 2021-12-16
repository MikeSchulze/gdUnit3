using System.Diagnostics;
using System.Collections;
using System.Linq;

using static GdUnit3.Assertions;

namespace GdUnit3
{
    public abstract class AssertBase<V> : IAssertBase<V>
    {
        protected readonly Godot.Reference _delegator;
        protected object Current { get; private set; }

        private EXPECT _expectResult;

        protected AssertBase(Godot.Reference delegator, object current, EXPECT expectResult = EXPECT.SUCCESS)
        {
            _delegator = delegator;
            Current = current;
            _expectResult = expectResult;
            StackFrame CallStack = new StackFrame(3, true);
            _delegator.Call("set_line_number", CallStack.GetFileLineNumber());
        }

        public IAssertBase<V> IsEqual(V expected)
        {
            var result = Comparable.IsEqual(Current, expected);
            if (!result.Valid)
            {
                _delegator.Call("report_error", AssertFailures.ErrorEqual(Current, expected));
                if (IsEnableInterruptOnFailure())
                    throw new TestFailedException("TestCase interuppted by a failing assert.", 2);
            }
            _delegator.Call("report_success");
            return this;
        }

        public IAssertBase<V> IsNotEqual(V expected)
        {
            var result = Comparable.IsEqual(Current, expected);
            if (result.Valid)
            {
                _delegator.Call("report_error", AssertFailures.ErrorNotEqual(Current, expected));
                if (IsEnableInterruptOnFailure())
                    throw new TestFailedException("TestCase interuppted by a failing assert.", 2);
            }
            _delegator.Call("report_success");
            return this;
        }

        public IAssertBase<V> IsNotNull()
        {
            return CallDelegator("is_not_null");
        }

        public IAssertBase<V> IsNull()
        {
            return CallDelegator("is_null");
        }

        public IAssert HasFailureMessage(string expected)
        {
            CallDelegator("has_failure_message", expected);
            return this;
        }

        public IAssert OverrideFailureMessage(string message)
        {
            _delegator.Call("override_failure_message", message);
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
            {
                return;
            }
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
    }
}
