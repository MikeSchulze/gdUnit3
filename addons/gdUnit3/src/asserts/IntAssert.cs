namespace GdUnit3
{
    internal sealed class IntAssert : NumberAssert<int>, IIntAssert
    {
        public IntAssert(int current) : base(current)
        { }
    }
}
