using System;

using static GdUnit3.Assertions;

namespace GdUnit3
{
    public sealed class ObjectAssert : AssertBase<object>, IObjectAssert
    {
        private static Godot.GDScript AssertImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdUnitObjectAssertImpl.gd");

        private static Godot.GDScript GdAssertMessages = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/asserts/GdAssertMessages.gd");

        private readonly Godot.Reference _messageBuilder;

        public ObjectAssert(object caller, object current, EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current)
        {
            _messageBuilder = GdAssertMessages.New() as Godot.Reference;
        }

        public IObjectAssert IsNotInstanceOf<ExpectedType>()
        {
            if (_current is ExpectedType)
            {
                var message = String.Format("Expected not be a instance of <{0}>", typeof(ExpectedType));
                _delegator.Call("report_error", message);
                if (IsEnableInterupptOnFailure())
                    throw new TestFailedException("TestCase interuppted by a failing assert.", 2);
                return this;
            }
            _delegator.Call("report_success");
            return this;
        }

        public IObjectAssert IsNotSame(object expected)
        {
            CallDelegator("is_not_same", expected);
            return this;
        }

        public IObjectAssert IsSame(object expected)
        {
            CallDelegator("is_same", expected);
            return this;
        }

        public IObjectAssert IsInstanceOf<ExpectedType>()
        {
            if (!(_current is ExpectedType))
            {
                var message = error_is_instanceof(_current != null ? _current.GetType() : null, typeof(ExpectedType));
                _delegator.Call("report_error", message);
                if (IsEnableInterupptOnFailure())
                    throw new TestFailedException("TestCase interuppted by a failing assert.", 2);
                return this;
            }
            _delegator.Call("report_success");
            return this;
        }

        public new IObjectAssert OverrideFailureMessage(string message)
        {
            return base.OverrideFailureMessage(message) as IObjectAssert;
        }

        private String format_expected(string value)
        {
            return _messageBuilder.Call("_expected", value) as string;
        }

        private String format_current(string value)
        {
            return _messageBuilder.Call("_current", value) as string;
        }

        private String format_error(string value)
        {
            return _messageBuilder.Call("_error", value) as string;
        }

        private string error_is_instanceof(Type current, Type expected)
        {
            return String.Format("{0}\n {1}\n But it was {2}",
                format_error("Expected instance of:"),
                format_expected(expected.ToString()),
                format_current(current != null ? current.ToString() : "Null"));
        }
    }
}
