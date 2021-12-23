using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace GdUnit3
{
    public sealed class ValueExtractor : IValueExtractor
    {
        private readonly IEnumerable<string> _methodNames;

        private readonly IEnumerable<object> _args;

        public ValueExtractor(string methodName, params object[] args)
        {
            _methodNames = methodName.Split('.');
            _args = args.ToList<object>();
        }

        public object ExtractValue(object value)
        {
            if (value == null)
                return null;

            try
            {
                foreach (var methodName in _methodNames)
                {
                    value = Extract(value, methodName);
                    if (value == null || value.Equals("n.a."))
                        return value;
                }
                return value;
            }
            catch (Exception e)
            {
                Godot.GD.PrintErr(e.Message, value, _methodNames);
                return "n.a.";
            }
        }

        private object Extract(object instance, string name)
        {
            var type = instance.GetType();
            var method = type.GetMethod(name, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            if (method != null)
            {
                return method.Invoke(instance, _args.ToArray());
            }
            var property = type.GetProperty(name, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            if (property == null)
            {
                //if GdUnitSettings.is_verbose_assert_warnings():
                //    Godot.GD.PushWarning("Extracting value from element '%s' by func '%s' failed! Converting to \"n.a.\"" % [instance, func_name])
                return "n.a.";
            }
            return property.GetValue(instance);

        }
    }
}
