using System;
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

        public IAssertBase<V> HasFailureMessage(string expected)
        {
            _delegator.Call("has_failure_message", expected);
            return this;
        }

        public IAssertBase<V> IsEqual(V expected)
        {
            _delegator.Call("is_equal", expected);
            return this;
        }

        public IAssertBase<V> IsNotEqual(V expected)
        {
            _delegator.Call("is_not_equal", expected);
            return this;
        }

        public IAssertBase<V> IsNotNull()
        {
            _delegator.Call("is_not_null");
            return this;
        }

        public IAssertBase<V> IsNull()
        {
            _delegator.Call("is_null");
            return this;
        }

        public IAssertBase<V> OverrideFailureMessage(string message)
        {
            _delegator.Call("override_failure_message", message);
            return this;
        }

        public IAssertBase<V> StartsWithFailureMessage(string message)
        {
            _delegator.Call("starts_with_failure_message", message);
            return this;
        }

        public IAssertBase<V> TestFail()
        {
            _delegator.Call("test_fail");
            return this;
        }

        private void InteruptOnFail()
        {
            if (!IsEnableInterupptOnFailure())
            {
                return;
            }
            var isFailed = (bool)_delegator.Call("is_failed");
            if (isFailed == true)
            {
                throw new System.Exception("TestCase interuppted by a failing assert.");
            }
        }

        protected T CallDelegator<T>(string methodName, params object[] args) where T : IAssertBase<V>, IAssert
        {
            _delegator.Call(methodName, args);
            InteruptOnFail();
            return (T)Convert.ChangeType(this, typeof(T));
        }
    }
}
