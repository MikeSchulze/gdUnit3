using System.Diagnostics;

using static GdUnit3.Assertions;

namespace GdUnit3
{
    public abstract class AssertBase<V> : IAssertBase<V>
    {
        protected readonly Godot.Reference _delegator;
        protected readonly object _current;

        private EXPECT _expectResult;

        protected AssertBase(Godot.Reference delegator, object current = null, EXPECT expectResult = EXPECT.SUCCESS)
        {
            _delegator = delegator;
            _current = current;
            _expectResult = expectResult;
            StackFrame CallStack = new StackFrame(3, true);
            _delegator.Call("set_line_number", CallStack.GetFileLineNumber());
        }

        public IAssertBase<V> IsEqual(V expected)
        {
            return CallDelegator("is_equal", expected);
        }

        public IAssertBase<V> IsNotEqual(V expected)
        {
            return CallDelegator("is_not_equal", expected);
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

        private void InteruptOnFail()
        {
            if (!IsEnableInterupptOnFailure())
            {
                return;
            }
            var isFailed = (bool)_delegator.Call("is_failed");
            if (isFailed)
            {
                throw new TestFailedException("TestCase interuppted by a failing assert.");
            }
        }

        protected IAssertBase<V> CallDelegator(string methodName, params object[] args)
        {
            _delegator.Call(methodName, args);
            InteruptOnFail();
            return this;
        }
    }
}
