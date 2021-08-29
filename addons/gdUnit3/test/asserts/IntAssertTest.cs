using GdUnit3;
using Godot;
using static GdUnit3.IAssert.EXPECT;

[TestSuite]
public class IntAssertTest : TestSuite
{

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
        AssertInt(23).IsLess(42);
        AssertInt(23).IsLess(24);
        // this assertion fails because 23 is not less than 23
        AssertInt(23, FAIL)
            .IsLess(23)
            .HasFailureMessage("Expecting to be less than:\n '23' but was '23'");
    }

    [TestCase]
    public void IsLessEqual()
    {
        AssertInt(23).IsLessEqual(42);
        AssertInt(23).IsLessEqual(23);
        // this assertion fails because 23 is not less than or equal to 22
        AssertInt(23, FAIL)
            .IsLessEqual(22)
            .HasFailureMessage("Expecting to be less than or equal:\n '22' but was '23'");
    }

    [TestCase]
    public void IsGreater()
    {
        AssertInt(23).IsGreater(20);
        AssertInt(23).IsGreater(22);
        // this assertion fails because 23 is not greater than 23
        AssertInt(23, FAIL)
            .IsGreater(23)
            .HasFailureMessage("Expecting to be greater than:\n '23' but was '23'");
    }

    [TestCase]
    public void IsGreaterEqual()
    {
        AssertInt(23).IsGreaterEqual(20);
        AssertInt(23).IsGreaterEqual(23);
        // this assertion fails because 23 is not greater than 23
        AssertInt(23, FAIL)
            .IsGreaterEqual(24)
            .HasFailureMessage("Expecting to be greater than or equal:\n '24' but was '23'");
    }

    //  [TestCase]
    //public void _test_IsEven_fuzz(fuzzer = Fuzzers.even(-9223372036854775807, 9223372036854775807))
    //{
    //  AssertInt(fuzzer.next_value()).IsEven()
    //}

    [TestCase]
    public void IsEven()
    {
        AssertInt(12).IsEven();
        AssertInt(13, FAIL)
            .IsEven()
            .HasFailureMessage("Expecting:\n '13' must be even");
    }

    [TestCase]
    public void IsOdd()
    {
        AssertInt(13).IsOdd();
        AssertInt(12, FAIL)
            .IsOdd()
            .HasFailureMessage("Expecting:\n '12' must be odd");
    }

    [TestCase]
    public void IsNegative()
    {
        AssertInt(-13).IsNegative();
        AssertInt(13, FAIL)
            .IsNegative()
            .HasFailureMessage("Expecting:\n '13' be negative");
    }

    [TestCase]
    public void IsNotNegative()
    {
        AssertInt(13).IsNotNegative();
        AssertInt(-13, FAIL)
            .IsNotNegative()
            .HasFailureMessage("Expecting:\n '-13' be not negative");
    }

    [TestCase]
    public void IsZero()
    {
        AssertInt(0).IsZero();
        // this assertion fail because the value is not zero
        AssertInt(1, FAIL)
            .IsZero()
            .HasFailureMessage("Expecting:\n equal to 0 but is '1'");
    }

    [TestCase]
    public void IsNotZero()
    {
        AssertInt(1).IsNotZero();
        // this assertion fail because the value is not zero
        AssertInt(0, FAIL)
            .IsNotZero()
            .HasFailureMessage("Expecting:\n not equal to 0");
    }

    [TestCase]
    public void IsIn()
    {
        AssertInt(5).IsIn(new int[] { 3, 4, 5, 6 });
        // this assertion fail because 7 is not in [3, 4, 5, 6]
        AssertInt(7, FAIL)
            .IsIn(new int[] { 3, 4, 5, 6 })
            .HasFailureMessage("Expecting:\n '7'\n is in\n '[3, 4, 5, 6]'");
    }

    [TestCase]
    public void IsNotIn()
    {
        AssertInt(5).IsNotIn(new int[] { 3, 4, 6, 7 });
        // this assertion fail because 7 is not in [3, 4, 5, 6]
        AssertInt(5, FAIL)
            .IsNotIn(new int[] { 3, 4, 5, 6 })
            .HasFailureMessage("Expecting:\n '5'\n is not in\n '[3, 4, 5, 6]'");
    }

    //[Theory]
    //[Fuzzer(name = "rangei", from = -20, to = 20)]
    [TestCase(timeout = 1000)]
    public void IsBetween()
    {
        int value = 10;
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
    public void override_failure_message([Fuzzer(10)] int value, [Fuzzer(5)] int value2 = 0)
    {
        GD.PrintS("iteration", value, value2);
        AssertInt(value, FAIL)
            .OverrideFailureMessage("Custom failure message")
            .IsNull()
            .HasFailureMessage("Custom failure message");
    }

    [BeforeTest]
    public void setup()
    {

    }

    [AfterTest]
    public void testFin()
    {

    }

    [IgnoreUntil("Ignore on self test")]
    [TestCase]
    public void Executor()
    {
        new Executor().execute(this);
    }


}
