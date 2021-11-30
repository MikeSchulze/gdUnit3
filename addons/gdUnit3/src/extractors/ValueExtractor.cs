using System.Collections.Generic;

namespace GdUnit3
{
    public sealed class ValueExtractor : IValueExtractor
    {
        private static Godot.GDScript ValueExtractorImpl = Godot.GD.Load<Godot.GDScript>("res://addons/gdUnit3/src/extractors/GdUnitFuncValueExtractor.gd");
        private readonly Godot.Reference _delegator;

        public ValueExtractor(string funcName, IEnumerable<object> args)
        {
            _delegator = (Godot.Reference)ValueExtractorImpl.New(funcName, args);
        }

        public object ExtractValue(object value) => _delegator.Call("extractValue", value);
    }
}
