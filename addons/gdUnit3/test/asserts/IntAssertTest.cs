namespace GdUnit3.Tests.Asserts
{
    using Exceptions;
    using Executions;
    using static Assertions;

    [TestSuite]
    public class IntAssertTest
    {
        [TestCase]
        public void IsNull()
        {
            AssertThrown(() => AssertInt(23).IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 13)
                .HasMessage("Expecting be <Null>:\n"
                    + " but is\n"
                    + "  '23'");
        }

        [TestCase]
        public void IsNotNull()
        {
            AssertInt(-23).IsNotNull();
            AssertInt(0).IsNotNull();
            AssertInt(23).IsNotNull();
        }

        [TestCase]
        public void IsEqual()
        {
            AssertInt(-23).IsEqual(-23);
            AssertInt(0).IsEqual(0);
            AssertInt(23).IsEqual(23);
            // this assertion fails because 23 are not equal to 42
            AssertThrown(() => AssertInt(23).IsEqual(42))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 36)
                .HasMessage("Expecting be equal:\n"
                    + "  '42' but is '23'");
        }

        [TestCase]
        public void IsNotEqual()
        {
            AssertInt(23).IsNotEqual(-23);
            AssertInt(23).IsNotEqual(42);
            // this assertion fails because 23 are equal to 23 
            AssertThrown(() => AssertInt(23).IsNotEqual(23))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 49)
                .HasMessage("Expecting be NOT equal:\n"
                    + "  '23' but is '23'");
        }

        [TestCase]
        public void IsLess()
        {
            AssertInt(-23).IsLess(-22);
            AssertInt(23).IsLess(42);
            AssertInt(23).IsLess(24);
            // this assertion fails because 23 is not less than 23
            AssertThrown(() => AssertInt(23).IsLess(23))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 63)
                .HasMessage("Expecting to be less than:\n"
                    + "  '23' but is '23'");
            AssertThrown(() => AssertInt(23).IsLess(22))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 68)
                .HasMessage("Expecting to be less than:\n"
                    + "  '22' but is '23'");
            AssertThrown(() => AssertInt(-23).IsLess(-23))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 73)
                .HasMessage("Expecting to be less than:\n"
                    + "  '-23' but is '-23'");
            AssertThrown(() => AssertInt(-23).IsLess(-24))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 78)
                .HasMessage("Expecting to be less than:\n"
                    + "  '-24' but is '-23'");
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
            AssertThrown(() => AssertInt(23).IsLessEqual(22)).IsInstanceOf<TestFailedException>()
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 94)
                .HasMessage("Expecting to be less than or equal:\n"
                    + "  '22' but is '23'");
            AssertThrown(() => AssertInt(-23).IsLessEqual(-24))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 99)
                .HasMessage("Expecting to be less than or equal:\n"
                    + "  '-24' but is '-23'");
        }

        [TestCase]
        public void IsGreater()
        {
            AssertInt(-23).IsGreater(-24);
            AssertInt(1).IsGreater(0);
            AssertInt(23).IsGreater(20);
            AssertInt(23).IsGreater(22);
            // this assertion fails because 23 is not greater than 23
            AssertThrown(() => AssertInt(23).IsGreater(23))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 114)
                .HasMessage("Expecting to be greater than:\n"
                    + "  '23' but is '23'");
            AssertThrown(() => AssertInt(23).IsGreater(24))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 119)
                .HasMessage("Expecting to be greater than:\n"
                    + "  '24' but is '23'");
            AssertThrown(() => AssertInt(-23).IsGreater(-23))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 124)
                .HasMessage("Expecting to be greater than:\n"
                    + "  '-23' but is '-23'");
            AssertThrown(() => AssertInt(-23).IsGreater(-22))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 129)
                .HasMessage("Expecting to be greater than:\n"
                    + "  '-22' but is '-23'");
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
            AssertThrown(() => AssertInt(23).IsGreaterEqual(24))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 145)
                .HasMessage("Expecting to be greater than or equal:\n"
                    + "  '24' but is '23'");
            AssertThrown(() => AssertInt(-23).IsGreaterEqual(-22))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 150)
                .HasMessage("Expecting to be greater than or equal:\n"
                    + "  '-22' but is '-23'");
        }

        [TestCase]
        public void IsEven()
        {
            AssertInt(-200).IsEven();
            AssertInt(-22).IsEven();
            AssertInt(0).IsEven();
            AssertInt(22).IsEven();
            AssertInt(200).IsEven();

            AssertThrown(() => AssertInt(-13).IsEven())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 166)
                .HasMessage("Expecting be even:\n"
                    + " but is '-13'");
            AssertThrown(() => AssertInt(13).IsEven())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 171)
                .HasMessage("Expecting be even:\n"
                    + " but is '13'");
        }

        [TestCase]
        public void IsOdd()
        {
            AssertInt(-13).IsOdd();
            AssertInt(13).IsOdd();
            AssertThrown(() => AssertInt(-12).IsOdd())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 183)
                .HasMessage("Expecting be odd:\n"
                    + " but is '-12'");
            AssertThrown(() => AssertInt(0).IsOdd())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 188)
                .HasMessage("Expecting be odd:\n"
                    + " but is '0'");
            AssertThrown(() => AssertInt(12).IsOdd())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 193)
                .HasMessage("Expecting be odd:\n"
                    + " but is '12'");
        }

        [TestCase]
        public void IsNegative()
        {
            AssertInt(-1).IsNegative();
            AssertInt(-23).IsNegative();
            AssertThrown(() => AssertInt(0).IsNegative())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 205)
                .HasMessage("Expecting be negative:\n"
                    + " but is '0'");
            AssertThrown(() => AssertInt(13).IsNegative())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 210)
                .HasMessage("Expecting be negative:\n"
                    + " but is '13'");
        }

        [TestCase]
        public void IsNotNegative()
        {
            AssertInt(0).IsNotNegative();
            AssertInt(13).IsNotNegative();
            AssertThrown(() => AssertInt(-1).IsNotNegative())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 222)
                .HasMessage("Expecting be NOT negative:\n"
                    + " but is '-1'");
            AssertThrown(() => AssertInt(-13).IsNotNegative())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 227)
                .HasMessage("Expecting be NOT negative:\n"
                    + " but is '-13'");
        }

        [TestCase]
        public void IsZero()
        {
            AssertInt(0).IsZero();
            // this assertion fail because the value is not zero
            AssertThrown(() => AssertInt(-1).IsZero())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 239)
                .HasMessage("Expecting be zero:\n"
                    + " but is '-1'");
            AssertThrown(() => AssertInt(1).IsZero())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 244)
                .HasMessage("Expecting be zero:\n"
                    + " but is '1'");
        }

        [TestCase]
        public void IsNotZero()
        {
            AssertInt(-1).IsNotZero();
            AssertInt(1).IsNotZero();
            // this assertion fail because the value is not zero
            AssertThrown(() => AssertInt(0).IsNotZero())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 257)
                .HasMessage("Expecting be NOT zero:\n"
                    + " but is '0'");
        }

        [TestCase]
        public void IsIn()
        {
            AssertInt(5).IsIn(3, 4, 5, 6);
            AssertInt(5).IsIn(new int[] { 3, 4, 5, 6 });
            // this assertion fail because 7 is not in [3, 4, 5, 6]
            AssertThrown(() => AssertInt(7).IsIn(new int[] { 3, 4, 5, 6 }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 270)
                .HasMessage("Expecting:\n"
                    + "  '7'\n"
                    + " is in\n"
                    + "  System.Int32[3, 4, 5, 6]");
            AssertThrown(() => AssertInt(7).IsIn(new int[] { }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 277)
                .HasMessage("Expecting:\n"
                    + "  '7'\n"
                    + " is in\n"
                    + "  System.Int32[]");
        }

        [TestCase]
        public void IsNotIn()
        {
            AssertInt(5).IsNotIn();
            AssertInt(5).IsNotIn(new int[] { });
            AssertInt(5).IsNotIn(new int[] { 3, 4, 6, 7 });
            AssertInt(5).IsNotIn(3, 4, 6, 7);
            // this assertion fail because 7 is not in [3, 4, 5, 6]
            AssertThrown(() => AssertInt(5).IsNotIn(new int[] { 3, 4, 5, 6 }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 294)
                .HasMessage("Expecting:\n"
                    + "  '5'\n"
                    + " is not in\n"
                    + "  System.Int32[3, 4, 5, 6]");
        }

        [TestCase(Iterations = 40)]
        public void IsBetween([Fuzzer(-20)] int value)
        {
            AssertInt(value).IsBetween(-20, 20);
        }

        [TestCase]
        public void IsBetweenMustFail()
        {
            AssertThrown(() => AssertInt(-10).IsBetween(-9, 0))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 312)
                .HasMessage("Expecting:\n"
                    + "  '-10'\n"
                    + " in range between\n"
                    + "  '-9' <> '0'");
            AssertThrown(() => AssertInt(0).IsBetween(1, 10))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 319)
                .HasMessage("Expecting:\n"
                    + "  '0'\n"
                    + " in range between\n"
                    + "  '1' <> '10'");
            AssertThrown(() => AssertInt(10).IsBetween(11, 21))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 326)
                .HasMessage("Expecting:\n"
                    + "  '10'\n"
                    + " in range between\n"
                    + "  '11' <> '21'");
        }

        [TestCase]
        public void OverrideFailureMessage()
        {
            AssertThrown(() => AssertInt(10)
                    .OverrideFailureMessage("Custom failure message")
                    .IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 338)
                .HasMessage("Custom failure message");
        }

        [TestCase]
        public void Interrupt_IsFailure()
        {
            // we disable failure reportion until we simmulate an failure
            ExecutionContext.Current.FailureReporting = false;
            // force an assertion failure
            AssertInt(10).IsZero();
            ExecutionContext.Current.FailureReporting = true;

            // expect this line will never called because of the test is interrupted by a failing assert
            AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
        }
    }
}
