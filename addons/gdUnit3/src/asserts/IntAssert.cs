namespace GdUnit3
{
    public sealed class IntAssert : NumberAssert<int>, IIntAssert
    {
        public IntAssert(int current) : base(current)
        { }
    }
}
