namespace GdUnit3
{
    internal sealed class DoubleAssert : NumberAssert<double>, IDoubleAssert
    {
        public DoubleAssert(double current) : base(current)
        { }
    }
}
