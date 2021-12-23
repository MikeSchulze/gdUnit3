namespace GdUnit3
{
    public sealed class DoubleAssert : NumberAssert<double>, IDoubleAssert
    {
        public DoubleAssert(double current) : base(current)
        { }
    }
}
