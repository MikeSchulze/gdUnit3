using GdUnit3;
using Godot;
using static GdUnit3.IAssert.EXPECT;

[TestSuite]
public class ArrayAssertTest : TestSuite
{


    [TestCase]
    public void IsNull()
    {
        AssertArray(null).IsNull();

        // should fail because the current is not null
        AssertArray(new object[] { }, FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was empty");

        AssertArray(new int[] { }, FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was empty");
        // with godot array
        AssertArray(new Godot.Collections.Array(), FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was empty");
    }

    [TestCase]
    public void IsNotNull()
    {

        AssertArray(new object[] { }).IsNotNull();
        AssertArray(new int[] { }).IsNotNull();
        AssertArray(System.Array.Empty<int>()).IsNotNull();
        AssertArray(new Godot.Collections.Array()).IsNotNull();

        // should fail because the current is null
        AssertArray(null, FAIL)
            .IsNotNull()
            .StartsWithFailureMessage("Expecting: not to be 'Null'");
    }

    [TestCase]
    public void IsEqual()
    {
        AssertArray(new object[] { }).IsEqual(new object[] { });
        AssertArray(new int[] { }).IsEqual(new int[] { });
        AssertArray(System.Array.Empty<int>()).IsEqual(System.Array.Empty<int>());
        AssertArray(new Godot.Collections.Array()).IsEqual(new Godot.Collections.Array());

        AssertArray(new int[] { 1, 2, 4, 5 }).IsEqual(new int[] { 1, 2, 4, 5 });

        AssertArray(new int[] { 1, 2, 4, 5 }, FAIL).IsEqual(new int[] { 1, 2, 3, 4, 2, 5 });
        //.HasFailureMessage("Expecting:\n ");
    }

    [TestCase]
    public void IsEqualIgnoringCase()
    {
        AssertArray(new string[] { "this", "is", "a", "message" }).IsEqualIgnoringCase(new string[] { "This", "is", "a", "Message" });
        // should fail because the array not contains same elements
        AssertArray(new string[] { "this", "is", "a", "message" }, FAIL).IsEqualIgnoringCase(new string[] { "This", "is", "an", "Message" });
    }

    [TestCase]
    public void IsNotEqual()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).IsNotEqual(new int[] { 1, 2, 3, 4, 5, 6 });
        // should fail because the array  contains same elements
        AssertArray(new int[] { 1, 2, 3, 4, 5 }, FAIL).IsNotEqual(new int[] { 1, 2, 3, 4, 5 });
    }

    [TestCase]
    public void IsNotEqualIgnoringCase()
    {
        AssertArray(new string[] { "this", "is", "a", "message" }).IsNotEqualIgnoringCase(new string[] { "This", "is", "an", "Message" });
        // should fail because the array contains same elements ignoring case sensitive
        AssertArray(new string[] { "this", "is", "a", "message" }, FAIL).IsNotEqualIgnoringCase(new string[] { "This", "is", "a", "Message" });
    }

    [TestCase]
    public void IsEmpty()
    {
        AssertArray(new int[] { }).IsEmpty();
        // should fail because the array is not empty it has a size of one
        AssertArray(new int[] { 1 }, FAIL).IsEmpty()
            .HasFailureMessage("Expecting:\n must be empty but was\n 1");
    }

    [TestCase]
    public void IsNotEmpty()
    {
        AssertArray(new int[] { 1 }).IsNotEmpty();
        // should fail because the array is empty
        AssertArray(new int[] { }, FAIL).IsNotEmpty()
            .HasFailureMessage("Expecting:\n must not be empty");
    }

    // TODO continue test coverage here
}
