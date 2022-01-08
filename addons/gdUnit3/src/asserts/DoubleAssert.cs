namespace GdUnit3.Asserts
{
    internal sealed class DoubleAssert : NumberAssert<double>, IDoubleAssert
    {
        public DoubleAssert(double current) : base(current)
        { }
    }
}
