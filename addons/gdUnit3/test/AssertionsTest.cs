namespace GdUnit3.Tests
{
	using Exceptions;
	using static Assertions;
	using static Utils;

    [TestSuite]
    public class AssertionsTest
    {

        [TestCase]
        public void DoAssertNotYetImplemented()
        {
            AssertThrown(() => AssertNotYetImplemented())
                .HasPropertyValue("LineNumber", 13)
                .HasMessage("Test not yet implemented!");
        }

    }
}