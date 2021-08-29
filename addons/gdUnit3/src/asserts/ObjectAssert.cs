using Godot;
using System;

namespace GdUnit3
{
    public sealed class ObjectAssert : AssertBase<object>, IObjectAssert
    {
        private static Godot.GDScript AssertImpl = GD.Load<GDScript>("res://addons/gdUnit3/src/asserts/GdUnitObjectAssertImpl.gd");

        private static Godot.GDScript GdAssertMessages = GD.Load<GDScript>("res://addons/gdUnit3/src/asserts/GdAssertMessages.gd");

        private readonly Godot.Reference _messageBuilder;

        public ObjectAssert(object caller, object current, IAssert.EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult), current)
        {
            _messageBuilder = GdAssertMessages.New() as Godot.Reference;
        }


        public IObjectAssert IsNotInstanceof<ExpectedType>()
        {
            if (_current is ExpectedType)
            {
                var message = String.Format("Expected not be a instance of <{0}>", typeof(ExpectedType));
                _delegator.Call("report_error", message);
                return this;
            }
            _delegator.Call("report_success");
            return this;
        }

        public IObjectAssert IsNotSame(object expected)
        {
            _delegator.Call("is_not_same", expected);
            return this;
        }

        public IObjectAssert IsSame(object expected)
        {
            _delegator.Call("is_same", expected);
            return this;
        }

        public IObjectAssert IsInstanceof<ExpectedType>()
        {
            if (!(_current is ExpectedType))
            {
                var message = error_is_instanceof(_current != null ? _current.GetType() : null, typeof(ExpectedType));
                _delegator.Call("report_error", message);
                return this;
            }
            _delegator.Call("report_success");
            return this;
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
