using GdUnit3;

using static GdUnit3.Assertions;
using static GdUnit3.Assertions.EXPECT;

[TestSuite]
public class BoolAssertTest : TestSuite
{
    [BeforeTest]
    public void Setup()
    {
        // disable default fail fast behavior because we tests also for failing asserts see EXPECT.FAIL
        EnableInterruptOnFailure(false);
    }

    [TestCase]
    public void IsTrue()
    {
        AssertBool(true).IsTrue();
        AssertBool(false, FAIL).IsTrue()
            .HasFailureMessage("Expecting: 'True' but is 'False'");
    }

    [TestCase]
    public void IsFalse()
    {
        AssertBool(false).IsFalse();
        AssertBool(true, FAIL).IsFalse()
            .HasFailureMessage("Expecting: 'False' but is 'True'");
    }

    [TestCase]
    public void IsNull()
    {
        AssertBool(true, FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was 'True'");
        AssertBool(false, FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was 'False'");
    }

    [TestCase]
    public void IsNotNull()
    {
        AssertBool(true).IsNotNull();
        AssertBool(false).IsNotNull();
    }

    [TestCase]
    public void IsEqual()
    {
        AssertBool(true).IsEqual(true);
        AssertBool(false).IsEqual(false);
        AssertBool(true, FAIL)
            .IsEqual(false)
            .HasFailureMessage("Expecting:\n 'False'\n but was\n 'True'");
    }

    [TestCase]
    public void IsNotEqual()
    {
        AssertBool(true).IsNotEqual(false);
        AssertBool(false).IsNotEqual(true);
        AssertBool(true, FAIL)
            .IsNotEqual(true)
            .HasFailureMessage("Expecting:\n 'True'\n not equal to\n 'True'");
    }

    [TestCase]
    public void Fluent()
    {
        AssertBool(true).IsTrue()
            .IsEqual(true)
            .IsNotEqual(false)
            .IsNotNull();
    }

    [TestCase]
    public void OverrideFailureMessage()
    {
        AssertBool(true, FAIL)
            .OverrideFailureMessage("Custom failure message")
            .IsFalse()
            .HasFailureMessage("Custom failure message");
    }

    [TestCase]
    public void Interrupt_IsFailure()
    {
        // we want to interrupt on first failure
        EnableInterruptOnFailure(true);
        // try to fail
        AssertBool(true, FAIL).IsFalse();

        // expect this line will never called because of the test is inteerupted by a failing assert
        AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
    }
}
