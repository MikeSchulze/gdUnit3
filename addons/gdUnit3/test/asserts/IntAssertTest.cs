using GdUnit3;

using static GdUnit3.Assertions;
using static GdUnit3.Assertions.EXPECT;

[TestSuite]
public class IntAssertTest : TestSuite
{
    [BeforeTest]
    public void Setup()
    {
        // disable default fail fast behavior because we tests also for failing asserts see EXPECT.FAIL
        EnableInterruptOnFailure(false);
    }

    [TestCase]
    public void IsNull()
    {
        // should fail because the current is not null
        AssertInt(23, FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was '23'");
    }

    [TestCase]
    public void IsNotNull()
    {
        AssertInt(23).IsNotNull();
    }

    [TestCase]
    public void IsEqual()
    {
        AssertInt(23).IsEqual(23);
        // this assertion fails because 23 are not equal to 42
        AssertInt(23, FAIL)
            .IsEqual(42)
            .HasFailureMessage("Expecting:\n '42'\n but was\n '23'");
    }

    [TestCase]
    public void IsNotEqual()
    {
        AssertInt(23).IsNotEqual(42);
        // this assertion fails because 23 are equal to 23 
        AssertInt(23, FAIL)
            .IsNotEqual(23)
            .HasFailureMessage("Expecting:\n '23'\n not equal to\n '23'");
    }

    [TestCase]
    public void IsLess()
    {
        AssertInt(-23).IsLess(-22);
        AssertInt(23).IsLess(42);
        AssertInt(23).IsLess(24);
        // this assertion fails because 23 is not less than 23
        AssertInt(23, FAIL)
            .IsLess(23)
            .HasFailureMessage("Expecting to be less than:\n '23' but was '23'");
        AssertInt(23, FAIL)
            .IsLess(22)
            .HasFailureMessage("Expecting to be less than:\n '22' but was '23'");
        AssertInt(-23, FAIL)
            .IsLess(-23)
            .HasFailureMessage("Expecting to be less than:\n '-23' but was '-23'");
        AssertInt(-23, FAIL)
            .IsLess(-24)
            .HasFailureMessage("Expecting to be less than:\n '-24' but was '-23'");
    }

    [TestCase]
    public void IsLessEqual()
    {
        AssertInt(-23).IsLessEqual(-22);
        AssertInt(-23).IsLessEqual(-23);
        AssertInt(0).IsLessEqual(0);
        AssertInt(23).IsLessEqual(23);
        AssertInt(23).IsLessEqual(42);
        // this assertion fails because 23 is not less than or equal to 22
        AssertInt(23, FAIL)
            .IsLessEqual(22)
            .HasFailureMessage("Expecting to be less than or equal:\n '22' but was '23'");
        AssertInt(-23, FAIL)
            .IsLessEqual(-24)
            .HasFailureMessage("Expecting to be less than or equal:\n '-24' but was '-23'");
    }

    [TestCase]
    public void IsGreater()
    {
        AssertInt(-23).IsGreater(-24);
        AssertInt(1).IsGreater(0);
        AssertInt(23).IsGreater(20);
        AssertInt(23).IsGreater(22);
        // this assertion fails because 23 is not greater than 23
        AssertInt(23, FAIL)
            .IsGreater(23)
            .HasFailureMessage("Expecting to be greater than:\n '23' but was '23'");
        AssertInt(23, FAIL)
            .IsGreater(24)
            .HasFailureMessage("Expecting to be greater than:\n '24' but was '23'");
        AssertInt(-23, FAIL)
            .IsGreater(-23)
            .HasFailureMessage("Expecting to be greater than:\n '-23' but was '-23'");
        AssertInt(-23, FAIL)
            .IsGreater(-22)
            .HasFailureMessage("Expecting to be greater than:\n '-22' but was '-23'");
    }

    [TestCase]
    public void IsGreaterEqual()
    {
        AssertInt(-23).IsGreaterEqual(-24);
        AssertInt(-23).IsGreaterEqual(-23);
        AssertInt(0).IsGreaterEqual(0);
        AssertInt(23).IsGreaterEqual(20);
        AssertInt(23).IsGreaterEqual(23);
        // this assertion fails because 23 is not greater than 23
        AssertInt(23, FAIL)
            .IsGreaterEqual(24)
            .HasFailureMessage("Expecting to be greater than or equal:\n '24' but was '23'");
        AssertInt(-23, FAIL)
            .IsGreaterEqual(-22)
            .HasFailureMessage("Expecting to be greater than or equal:\n '-22' but was '-23'");
    }

    [TestCase]
    public void IsEven()
    {
        AssertInt(-200).IsEven();
        AssertInt(-22).IsEven();
        AssertInt(0).IsEven();
        AssertInt(22).IsEven();
        AssertInt(200).IsEven();

        AssertInt(-13, FAIL)
            .IsEven()
            .HasFailureMessage("Expecting:\n '-13' must be even");
        AssertInt(13, FAIL)
            .IsEven()
            .HasFailureMessage("Expecting:\n '13' must be even");
    }

    [TestCase]
    public void IsOdd()
    {
        AssertInt(-13).IsOdd();
        AssertInt(13).IsOdd();
        AssertInt(-12, FAIL)
            .IsOdd()
            .HasFailureMessage("Expecting:\n '-12' must be odd");
        AssertInt(0, FAIL)
            .IsOdd()
            .HasFailureMessage("Expecting:\n '0' must be odd");
        AssertInt(12, FAIL)
            .IsOdd()
            .HasFailureMessage("Expecting:\n '12' must be odd");
    }

    [TestCase]
    public void IsNegative()
    {
        AssertInt(-1).IsNegative();
        AssertInt(-23).IsNegative();
        AssertInt(0, FAIL)
            .IsNegative()
            .HasFailureMessage("Expecting:\n '0' be negative");
        AssertInt(13, FAIL)
            .IsNegative()
            .HasFailureMessage("Expecting:\n '13' be negative");
    }

    [TestCase]
    public void IsNotNegative()
    {
        AssertInt(0).IsNotNegative();
        AssertInt(13).IsNotNegative();
        AssertInt(-1, FAIL)
            .IsNotNegative()
            .HasFailureMessage("Expecting:\n '-1' be not negative");
        AssertInt(-13, FAIL)
            .IsNotNegative()
            .HasFailureMessage("Expecting:\n '-13' be not negative");
    }

    [TestCase]
    public void IsZero()
    {
        AssertInt(0).IsZero();
        // this assertion fail because the value is not zero
        AssertInt(-1, FAIL)
            .IsZero()
            .HasFailureMessage("Expecting:\n zero but is '-1'");
        AssertInt(1, FAIL)
            .IsZero()
            .HasFailureMessage("Expecting:\n zero but is '1'");
    }

    [TestCase]
    public void IsNotZero()
    {
        AssertInt(-1).IsNotZero();
        AssertInt(1).IsNotZero();
        // this assertion fail because the value is not zero
        AssertInt(0, FAIL)
            .IsNotZero()
            .HasFailureMessage("Expecting:\n not zero");
    }

    [TestCase]
    public void IsIn()
    {
        AssertInt(5).IsIn(new int[] { 3, 4, 5, 6 });
        // this assertion fail because 7 is not in [3, 4, 5, 6]
        AssertInt(7, FAIL)
            .IsIn(new int[] { 3, 4, 5, 6 })
            .HasFailureMessage("Expecting:\n"
                + " '7'\n"
                + " is in\n"
                + " System.Int32[] [3, 4, 5, 6]");
        AssertInt(7, FAIL)
            .IsIn(new int[] { })
            .HasFailureMessage("Expecting:\n"
                + " '7'\n"
                + " is in\n"
                + " empty System.Int32[]");
    }

    [TestCase]
    public void IsNotIn()
    {
        AssertInt(5).IsNotIn(new int[] { });
        AssertInt(5).IsNotIn(new int[] { 3, 4, 6, 7 });
        // this assertion fail because 7 is not in [3, 4, 5, 6]
        AssertInt(5, FAIL)
            .IsNotIn(new int[] { 3, 4, 5, 6 })
            .HasFailureMessage("Expecting:\n"
                + " '5'\n"
                + " is not in\n"
                + " System.Int32[] [3, 4, 5, 6]");
    }

    [TestCase(iterations = 40)]
    public void IsBetween([Fuzzer(-20)] int value)
    {
        AssertInt(value).IsBetween(-20, 20);
    }

    [TestCase]
    public void IsBetweenMustFail()
    {
        AssertInt(-10, FAIL)
            .IsBetween(-9, 0)
            .HasFailureMessage("Expecting:\n '-10'\n in range between\n '-9' <> '0'");
        AssertInt(0, FAIL)
            .IsBetween(1, 10)
            .HasFailureMessage("Expecting:\n '0'\n in range between\n '1' <> '10'");
        AssertInt(10, FAIL)
            .IsBetween(11, 21)
            .HasFailureMessage("Expecting:\n '10'\n in range between\n '11' <> '21'");
    }

    [TestCase(timeout = 20, seed = 111, iterations = 20)]
    public void OverrideFailureMessage([Fuzzer(10)] int value, [Fuzzer(5)] int value2 = 0)
    {
        AssertInt(value, FAIL)
            .OverrideFailureMessage("Custom failure message")
            .IsNull()
            .HasFailureMessage("Custom failure message");
    }

    [TestCase]
    public void Interrupt_IsFailure()
    {
        // we want to interrupt on first failure
        EnableInterruptOnFailure(true);
        // try to fail
        AssertInt(10, FAIL).IsZero();

        // expect this line will never called because of the test is interrupted by a failing assert
        AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
    }
}
