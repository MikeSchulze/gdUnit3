namespace GdUnit3.Tests
{
    using static Assertions;

    [TestSuite]
    public class AssertionsTest
    {

        [TestCase]
        public void DoAssertNotYetImplemented()
        {
            AssertThrown(() => AssertNotYetImplemented())
                .HasPropertyValue("LineNumber", 12)
                .HasMessage("Test not yet implemented!");
        }

    }
}
