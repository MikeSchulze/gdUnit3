namespace GdUnit3.Asserts
{
    internal sealed class IntAssert : NumberAssert<int>, IIntAssert
    {
        public IntAssert(int current) : base(current)
        { }
    }
}
