namespace GdUnit3.Tests.Asserts
{
    using Exceptions;
    using Executions;
    using static Assertions;
    using static GdUnit3.Asserts.IStringAssert.Compare;

    [TestSuite]
    public class StringAssertTest
    {
        [TestCase]
        public void IsNull()
        {
            AssertString(null).IsNull();
            // should fail because the current is not null
            AssertThrown(() => AssertString("abc").IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 16)
                .StartsWithMessage("Expecting be <Null>:\n"
                    + " but is\n"
                    + "  'abc'");
        }

        [TestCase]
        public void IsNotNull()
        {
            AssertString("abc").IsNotNull();
            // should fail because the current is null
            AssertThrown(() => AssertString(null).IsNotNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 29)
                .HasMessage("Expecting be NOT <Null>:");
        }

        [TestCase]
        public void IsEqual()
        {
            AssertString("This is a test message").IsEqual("This is a test message");
            AssertThrown(() => AssertString("This is a test message").IsEqual("This is a test Message"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 39)
                .HasMessage("Expecting be equal:\n"
                    + "  'This is a test Message'\n"
                    + " but is\n"
                    + "  'This is a test message'");
            AssertThrown(() => AssertString(null).IsEqual("This is a test Message"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 46)
                .HasMessage("Expecting be equal:\n"
                    + "  'This is a test Message'\n"
                    + " but is\n"
                    + "  <Null>");
        }

        [TestCase]
        public void IsEqualIgnoringCase()
        {
            AssertString("This is a test message").IsEqualIgnoringCase("This is a test Message");
            AssertThrown(() => AssertString("This is a test message").IsEqualIgnoringCase("This is a Message"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 59)
                .HasMessage("Expecting be equal (ignoring case):\n"
                    + "  'This is a Message'\n"
                    + " but is\n"
                    + "  'This is a test message'");
            AssertThrown(() => AssertString(null).IsEqualIgnoringCase("This is a Message"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 66)
                .HasMessage("Expecting be equal (ignoring case):\n"
                    + "  'This is a Message'\n"
                    + " but is\n"
                    + "  <Null>");
        }

        [TestCase]
        public void IsNotEqual()
        {
            AssertString(null).IsNotEqual("This is a test message");
            AssertString("This is a test message").IsNotEqual("This is a test Message");
            AssertThrown(() => AssertString("This is a test message").IsNotEqual("This is a test message"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 80)
                .HasMessage("Expecting be NOT equal:\n"
                    + "  'This is a test message'\n"
                    + " but is\n"
                    + "  'This is a test message'");
        }

        [TestCase]
        public void IsNotEqualIgnoringCase()
        {
            AssertString(null).IsNotEqualIgnoringCase("This is a Message");
            AssertString("This is a test message").IsNotEqualIgnoringCase("This is a Message");
            AssertThrown(() => AssertString("This is a test message").IsNotEqualIgnoringCase("This is a test Message"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 94)
                .HasMessage("Expecting be NOT equal (ignoring case):\n"
                    + "  'This is a test Message'\n"
                    + " but is\n"
                    + "  'This is a test message'");
        }

        [TestCase]
        public void IsEmpty()
        {
            AssertString("").IsEmpty();
            // should fail because the current value is not empty it contains a space
            AssertThrown(() => AssertString(" ").IsEmpty())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 108)
                .HasMessage("Expecting be empty:\n"
                    + " but is\n"
                    + "  ' '");
            AssertThrown(() => AssertString("abc").IsEmpty())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 114)
                .HasMessage("Expecting be empty:\n"
                    + " but is\n"
                    + "  'abc'");
            AssertThrown(() => AssertString(null).IsEmpty())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 120)
                .HasMessage("Expecting be empty:\n"
                    + " but is\n"
                    + "  <Null>");
        }

        [TestCase]
        public void IsNotEmpty()
        {
            AssertString(null).IsNotEmpty();
            AssertString(" ").IsNotEmpty();
            AssertString("	").IsNotEmpty();
            AssertString("abc").IsNotEmpty();
            // should fail because current is empty
            AssertThrown(() => AssertString("").IsNotEmpty())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 136)
                .HasMessage("Expecting being NOT empty:\n"
                    + " but is empty");
        }

        [TestCase]
        public void Contains()
        {
            AssertString("This is a test message").Contains("a test");
            // must fail because of camel case difference
            AssertThrown(() => AssertString("This is a test message").Contains("a Test"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 148)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " do contains\n"
                    + "  'a Test'");
            AssertThrown(() => AssertString(null).Contains("a Test"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 155)
                .HasMessage("Expecting:\n"
                    + "  <Null>\n"
                    + " do contains\n"
                    + "  'a Test'");
        }

        [TestCase]
        public void NotContains()
        {
            AssertString(null).NotContains("a tezt");
            AssertString("This is a test message").NotContains("a tezt");
            AssertThrown(() => AssertString("This is a test message").NotContains("a test"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 169)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " do not contain\n"
                    + "  'a test'");
        }

        [TestCase]
        public void ContainsIgnoringCase()
        {
            AssertString("This is a test message").ContainsIgnoringCase("a Test");
            AssertThrown(() => AssertString("This is a test message").ContainsIgnoringCase("a Tesd"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 182)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " do contains (ignoring case)\n"
                    + "  'a Tesd'");
            AssertThrown(() => AssertString(null).ContainsIgnoringCase("a Tesd"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 189)
                .HasMessage("Expecting:\n"
                    + "  <Null>\n"
                    + " do contains (ignoring case)\n"
                    + "  'a Tesd'");
        }

        [TestCase]
        public void NotContainsIgnoringCase()
        {
            AssertString(null).NotContainsIgnoringCase("a Tezt");
            AssertString("This is a test message").NotContainsIgnoringCase("a Tezt");
            AssertThrown(() => AssertString("This is a test message").NotContainsIgnoringCase("a Test"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 203)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " do not contain (ignoring case)\n"
                    + "  'a Test'");
        }

        [TestCase]
        public void StartsWith()
        {
            AssertString("This is a test message").StartsWith("This is");
            AssertThrown(() => AssertString("This is a test message").StartsWith("This iss"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 216)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " to start with\n"
                    + "  'This iss'");
            AssertThrown(() => AssertString("This is a test message").StartsWith("this is"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 223)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " to start with\n"
                    + "  'this is'");
            AssertThrown(() => AssertString("This is a test message").StartsWith("test"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 230)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " to start with\n"
                    + "  'test'");
            AssertThrown(() => AssertString(null).StartsWith("test"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 237)
                .HasMessage("Expecting:\n"
                    + "  <Null>\n"
                    + " to start with\n"
                    + "  'test'");
        }

        [TestCase]
        public void EndsWith()
        {
            AssertString("This is a test message").EndsWith("test message");
            AssertThrown(() => AssertString("This is a test message").EndsWith("tes message"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 250)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " to end with\n"
                    + "  'tes message'");
            AssertThrown(() => AssertString("This is a test message").EndsWith("a test"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 257)
                .HasMessage("Expecting:\n"
                    + "  'This is a test message'\n"
                    + " to end with\n"
                    + "  'a test'");
            AssertThrown(() => AssertString(null).EndsWith("a test"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 264)
                .HasMessage("Expecting:\n"
                    + "  <Null>\n"
                    + " to end with\n"
                    + "  'a test'");
        }

        [TestCase]
        public void HasLenght()
        {
            AssertString("This is a test message").HasLength(22);
            AssertString("").HasLength(0);
            AssertThrown(() => AssertString("This is a test message").HasLength(23))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 278)
                .HasMessage("Expecting length:\n"
                    + "  '23' but is '22'");
            AssertThrown(() => AssertString(null).HasLength(23))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 283)
                .HasMessage("Expecting length:\n"
                    + "  '23' but is <Null>");
        }

        [TestCase]
        public void HasLenghtLessThan()
        {
            AssertString("This is a test message").HasLength(23, LESS_THAN);
            AssertString("This is a test message").HasLength(42, LESS_THAN);
            AssertThrown(() => AssertString("This is a test message").HasLength(22, LESS_THAN))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 295)
                .HasMessage("Expecting length to be less than:\n"
                    + "  '22' but is '22'");
            AssertThrown(() => AssertString(null).HasLength(22, LESS_THAN))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 300)
                .HasMessage("Expecting length to be less than:\n"
                    + "  '22' but is <Null>");
        }

        [TestCase]
        public void HasLenghtLessEqual()
        {
            AssertString("This is a test message").HasLength(22, LESS_EQUAL);
            AssertString("This is a test message").HasLength(23, LESS_EQUAL);
            AssertThrown(() => AssertString("This is a test message").HasLength(21, LESS_EQUAL))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 312)
                .HasMessage("Expecting length to be less than or equal:\n"
                    + "  '21' but is '22'");
            AssertThrown(() => AssertString(null).HasLength(21, LESS_EQUAL))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 317)
                .HasMessage("Expecting length to be less than or equal:\n"
                    + "  '21' but is <Null>");
        }

        [TestCase]
        public void HasLenghtGreaterThan()
        {
            AssertString("This is a test message").HasLength(21, GREATER_THAN);
            AssertThrown(() => AssertString("This is a test message").HasLength(22, GREATER_THAN))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 328)
                .HasMessage("Expecting length to be greater than:\n"
                    + "  '22' but is '22'");
            AssertThrown(() => AssertString(null).HasLength(22, GREATER_THAN))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 333)
                .HasMessage("Expecting length to be greater than:\n"
                    + "  '22' but is <Null>");
        }

        [TestCase]
        public void HasLenghtGreaterEqual()
        {
            AssertString("This is a test message").HasLength(21, GREATER_EQUAL);
            AssertString("This is a test message").HasLength(22, GREATER_EQUAL);
            AssertThrown(() => AssertString("This is a test message").HasLength(23, GREATER_EQUAL))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 345)
                .HasMessage("Expecting length to be greater than or equal:\n"
                    + "  '23' but is '22'");
            AssertThrown(() => AssertString(null).HasLength(23, GREATER_EQUAL))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 350)
                .HasMessage("Expecting length to be greater than or equal:\n"
                    + "  '23' but is <Null>");
        }

        [TestCase]
        public void Fluent()
        {
            AssertString("value a").HasLength(7)
                .IsNotEqual("a")
                .IsEqual("value a")
                .IsNotNull();
        }

        [TestCase]
        public void OverrideFailureMessage()
        {
            AssertThrown(() => AssertString("").OverrideFailureMessage("Custom failure message").IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 369)
                .HasMessage("Custom failure message");
        }

        [TestCase]
        public void Interrupt_IsFailure()
        {
            // we disable failure reportion until we simmulate an failure
            ExecutionContext.Current.FailureReporting = false;
            // try to fail
            AssertString("").IsNotEmpty();
            ExecutionContext.Current.FailureReporting = true;

            // expect this line will never called because of the test is interrupted by a failing assert
            AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
        }
    }
}
