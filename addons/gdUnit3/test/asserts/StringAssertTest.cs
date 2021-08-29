
using GdUnit3;
using static GdUnit3.IAssert.EXPECT;
using static GdUnit3.IStringAssert.Compare;

[TestSuite]
public class StringAssertTest : TestSuite
{
    [TestCase]
    public void IsNull()
    {
        AssertString(null).IsNull();
        // should fail because the current is not null
        AssertString("abc", FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was 'abc'");
    }

    [TestCase]
    public void IsNotNull()
    {
        AssertString("abc").IsNotNull();
        // should fail because the current is null
        AssertString(null, FAIL)
            .IsNotNull()
            .HasFailureMessage("Expecting: not to be 'Null'");
    }

    [TestCase]
    public void IsEqual()
    {
        AssertString("This is a test message").IsEqual("This is a test message");
        AssertString("This is a test message", FAIL)
            .IsEqual("This is a test Message")
            .HasFailureMessage("Expecting:\n 'This is a test Message'\n but was\n 'This is a test Mmessage'");
    }

    [TestCase]
    public void IsEqualIgnoringCase()
    {
        AssertString("This is a test message").IsEqualIgnoringCase("This is a test Message");
        AssertString("This is a test message", FAIL)
            .IsEqualIgnoringCase("This is a Message")
            .HasFailureMessage("Expecting:\n 'This is a Message'\n but was\n 'This is a test Mmessage' (ignoring case)");
    }

    [TestCase]
    public void IsNotEqual()
    {
        AssertString("This is a test message").IsNotEqual("This is a test Message");
        AssertString("This is a test message", FAIL)
            .IsNotEqual("This is a test message")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n not equal to\n 'This is a test message'");
    }

    [TestCase]
    public void IsNotEqualIgnoringCase()
    {
        AssertString("This is a test message").IsNotEqualIgnoringCase("This is a Message");
        AssertString("This is a test message", FAIL)
            .IsNotEqualIgnoringCase("This is a test Message")
            .HasFailureMessage("Expecting:\n 'This is a test Message'\n not equal to\n 'This is a test message'");
    }

    [TestCase]
    public void IsEmpty()
    {
        AssertString("").IsEmpty();
        // should fail because the current value is not empty it contains a space
        AssertString(" ", FAIL)
            .IsEmpty()
            .HasFailureMessage("Expecting:\n must be empty but was\n ' '");
        AssertString("abc", FAIL)
            .IsEmpty()
            .HasFailureMessage("Expecting:\n must be empty but was\n 'abc'");
    }

    [TestCase]
    public void IsNotEmpty()
    {
        AssertString(" ").IsNotEmpty();
        AssertString("	").IsNotEmpty();
        AssertString("abc").IsNotEmpty();
        // should fail because current is empty
        AssertString("", FAIL)
            .IsNotEmpty()
            .HasFailureMessage("Expecting:\n must not be empty");
    }

    [TestCase]
    public void Contains()
    {
        AssertString("This is a test message").Contains("a test");
        // must fail because of camel case difference
        AssertString("This is a test message", FAIL)
            .Contains("a Test")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n do contains\n 'a Test'");
    }

    [TestCase]
    public void notContains()
    {
        AssertString("This is a test message").NotContains("a tezt");
        AssertString("This is a test message", FAIL)
            .NotContains("a test")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n not do contain\n 'a test'");
    }

    [TestCase]
    public void ContainsIgnoringCase()
    {
        AssertString("This is a test message").ContainsIgnoringCase("a Test");
        AssertString("This is a test message", FAIL)
            .ContainsIgnoringCase("a Tesd")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n contains\n 'a Tesd'\n (ignoring case)");
    }

    [TestCase]
    public void NotContainsIgnoringCase()
    {
        AssertString("This is a test message").NotContainsIgnoringCase("a Tezt");
        AssertString("This is a test message", FAIL)
            .NotContainsIgnoringCase("a Test")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n not do contains\n 'a Test'\n (ignoring case)");
    }

    [TestCase]
    public void StartsWith()
    {
        AssertString("This is a test message").StartsWith("This is");
        AssertString("This is a test message", FAIL)
            .StartsWith("This iss")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n to start with\n 'This iss'");
        AssertString("This is a test message", FAIL)
            .StartsWith("this is")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n to start with\n 'this is'");
        AssertString("This is a test message", FAIL)
            .StartsWith("test")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n to start with\n 'test'");
    }

    [TestCase]
    public void EndsWith()
    {
        AssertString("This is a test message").EndsWith("test message");
        AssertString("This is a test message", FAIL)
            .EndsWith("tes message")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n to end with\n 'tes message'");
        AssertString("This is a test message", FAIL)
            .EndsWith("a test")
            .HasFailureMessage("Expecting:\n 'This is a test message'\n to end with\n 'a test'");
    }

    [TestCase]
    public void HasLenght()
    {
        AssertString("This is a test message").HasLength(22);
        AssertString("").HasLength(0);
        AssertString("This is a test message", FAIL)
            .HasLength(23)
            .HasFailureMessage("Expecting size:\n '23' but was '22' in\n 'This is a test message'");
    }

    [TestCase]
    public void HasLenghtLessThan()
    {
        AssertString("This is a test message").HasLength(23, LESS_THAN);
        AssertString("This is a test message").HasLength(42, LESS_THAN);
        AssertString("This is a test message", FAIL)
            .HasLength(22, LESS_THAN)
            .HasFailureMessage("Expecting size to be less than:\n '22' but was '22' in\n 'This is a test message'");
    }

    [TestCase]
    public void HasLenghtLessEqual()
    {
        AssertString("This is a test message").HasLength(22, LESS_EQUAL);
        AssertString("This is a test message").HasLength(23, LESS_EQUAL);
        AssertString("This is a test message", FAIL)
            .HasLength(21, LESS_EQUAL)
            .HasFailureMessage("Expecting size to be less than or equal:\n '21' but was '22' in\n 'This is a test message'");
    }

    [TestCase]
    public void HasLenghtGreaterThan()
    {
        AssertString("This is a test message").HasLength(21, GREATER_THAN);
        AssertString("This is a test message", FAIL)
            .HasLength(22, GREATER_THAN)
            .HasFailureMessage("Expecting size to be greater than:\n '22' but was '22' in\n 'This is a test message'");
    }

    [TestCase]
    public void HasLenghtGreaterEqual()
    {
        AssertString("This is a test message").HasLength(21, GREATER_EQUAL);
        AssertString("This is a test message").HasLength(22, GREATER_EQUAL);
        AssertString("This is a test message", FAIL)
            .HasLength(23, GREATER_EQUAL)
            .HasFailureMessage("Expecting size to be greater than or equal:\n '23' but was '22' in\n 'This is a test message'");
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
        AssertString("", FAIL)
            .OverrideFailureMessage("Custom failure message")
            .IsNull()
            .HasFailureMessage("Custom failure message");
    }

}
