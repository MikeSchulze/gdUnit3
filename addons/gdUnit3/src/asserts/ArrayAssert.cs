using System.Collections;
using Godot;

namespace GdUnit3
{
    public sealed class ArrayAssert : AssertBase<IEnumerable>, IArrayAssert
    {
        private static Godot.GDScript AssertImpl = GD.Load<GDScript>("res://addons/gdUnit3/src/asserts/GdUnitArrayAssertImpl.gd");

        public ArrayAssert(object caller, IEnumerable current, IAssert.EXPECT expectResult)
            : base((Godot.Reference)AssertImpl.New(caller, current, expectResult))
        { }

        public IArrayAssert IsEqualIgnoringCase(IEnumerable expected)
        {
            _delegator.Call("is_equal_ignoring_case", expected);
            return this;
        }

        public IArrayAssert IsNotEqualIgnoringCase(IEnumerable expected)
        {
            _delegator.Call("is_not_equal_ignoring_case", expected);
            return this;
        }

        /// <summary> Verifies that the current Array is empty, it has a size of 0.</summary>
        public IArrayAssert IsEmpty()
        {
            _delegator.Call("is_empty");
            return this;
        }

        /// <summary> Verifies that the current Array is not empty, it has a size of minimum 1.</summary>
        public IArrayAssert IsNotEmpty()
        {
            _delegator.Call("is_not_empty");
            return this;
        }

    }
}
