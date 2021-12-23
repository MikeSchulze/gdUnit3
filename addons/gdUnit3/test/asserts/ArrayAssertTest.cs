using GdUnit3;
using Godot;

using static GdUnit3.Assertions;


[TestSuite]
public class ArrayAssertTest : TestSuite
{

    [TestCase]
    public void IsNull()
    {
        AssertArray(null).IsNull();

        // should fail because the current is not null
        AssertThrown(() => AssertArray(new object[] { }).IsNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 17)
            .StartsWithMessage("Expecting: 'Null' but is empty");
        AssertThrown(() => AssertArray(new int[] { }).IsNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 21)
            .StartsWithMessage("Expecting: 'Null' but is empty");
        // with godot array
        AssertThrown(() => AssertArray(new Godot.Collections.Array()).IsNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 26)
            .StartsWithMessage("Expecting: 'Null' but is empty");
    }

    [TestCase]
    public void IsNotNull()
    {

        AssertArray(new object[] { }).IsNotNull();
        AssertArray(new int[] { }).IsNotNull();
        AssertArray(System.Array.Empty<int>()).IsNotNull();
        AssertArray(new Godot.Collections.Array()).IsNotNull();

        // should fail because the current is null
        AssertThrown(() => AssertArray(null).IsNotNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 42)
            .StartsWithMessage("Expecting: not to be 'Null'");
    }

    [TestCase]
    public void IsEqual()
    {
        AssertArray(new object[] { }).IsEqual(new object[] { });
        AssertArray(new int[] { }).IsEqual(new int[] { });
        AssertArray(System.Array.Empty<int>()).IsEqual(System.Array.Empty<int>());
        AssertArray(new Godot.Collections.Array()).IsEqual(new Godot.Collections.Array());
        AssertArray(new int[] { 1, 2, 4, 5 }).IsEqual(new int[] { 1, 2, 4, 5 });
        AssertArray(new Godot.Collections.Array(new int[] { 1, 2, 4, 5 })).IsEqual(new Godot.Collections.Array(new int[] { 1, 2, 4, 5 }));

        AssertThrown(() => AssertArray(new int[] { 1, 2, 4, 5 }).IsEqual(new int[] { 1, 2, 3, 4, 2, 5 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 58)
            .HasMessage("Expecting:\n"
                + " System.Int32[] [1, 2, 3, 4, 2, 5]\n"
                + " be equal to\n"
                + " System.Int32[] [1, 2, 4, 5]");
        AssertThrown(() => AssertArray(new Godot.Collections.Array(new int[] { 1, 2, 4, 5 })).IsEqual(new Godot.Collections.Array(new int[] { 1, 2, 3, 4, 2, 5 })))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 65)
            .HasMessage("Expecting:\n"
                + " Godot.Collections.Array [1, 2, 3, 4, 2, 5]\n"
                + " be equal to\n"
                + " Godot.Collections.Array [1, 2, 4, 5]");
    }

    [TestCase]
    public void IsEqualIgnoringCase()
    {
        AssertArray(new string[] { "this", "is", "a", "message" }).IsEqualIgnoringCase(new string[] { "This", "is", "a", "Message" });
        // should fail because the array not contains same elements
        AssertThrown(() => AssertArray(new string[] { "this", "is", "a", "message" })
                .IsEqualIgnoringCase(new string[] { "This", "is", "an", "Message" }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 79)
            .HasMessage("Expecting:\n"
                + " System.String[] [This, is, an, Message]\n"
                + " be equal to (ignoring case)\n"
                + " System.String[] [this, is, a, message]");
    }

    [TestCase]
    public void IsNotEqual()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).IsNotEqual(new int[] { 1, 2, 3, 4, 5, 6 });
        // should fail because the array  contains same elements
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).IsNotEqual(new int[] { 1, 2, 3, 4, 5 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 94)
            .HasMessage("Expecting:\n"
                + " System.Int32[] [1, 2, 3, 4, 5]\n"
                + " not equal to\n"
                + " System.Int32[] [1, 2, 3, 4, 5]");
    }

    [TestCase]
    public void IsNotEqualIgnoringCase()
    {
        AssertArray(new string[] { "this", "is", "a", "message" }).IsNotEqualIgnoringCase(new string[] { "This", "is", "an", "Message" });
        // should fail because the array contains same elements ignoring case sensitive
        AssertThrown(() => AssertArray(new string[] { "this", "is", "a", "message" })
                .IsNotEqualIgnoringCase(new string[] { "This", "is", "a", "Message" }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 108)
            .HasMessage("Expecting:\n"
                + " System.String[] [This, is, a, Message]\n"
                + " not equal to\n"
                + " System.String[] [this, is, a, message]");
    }

    [TestCase]
    public void IsEmpty()
    {
        AssertArray(new int[] { }).IsEmpty();
        // should fail because the array is not empty it has a size of one
        AssertThrown(() => AssertArray(new int[] { 1 }).IsEmpty())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 123)
            .HasMessage("Expecting be empty:\n but has size '1'");
    }

    [TestCase]
    public void IsNotEmpty()
    {
        AssertArray(new int[] { 1 }).IsNotEmpty();
        // should fail because the array is empty
        AssertThrown(() => AssertArray(new int[] { }).IsNotEmpty())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 134)
            .HasMessage("Expecting not being empty:\n but is empty");
    }

    [TestCase]
    public void HasSize()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).HasSize(5);
        AssertArray(new string[] { "a", "b", "c", "d", "e", "f" }).HasSize(6);
        // should fail because the array has a size of 5
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).HasSize(4))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 146)
            .HasMessage("Expecting size:\n '4' but is '5'");
    }

    [TestCase]
    public void Contains_stringsAsArray()
    {
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).Contains(new string[] { });
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).Contains(new string[] { "ddd", "bbb" });
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).Contains(new string[] { "eee", "ddd", "ccc", "bbb", "aaa" });
        // should fail because the array not contains 'xxx' and 'yyy'
        AssertThrown(() => AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).Contains(new string[] { "bbb", "xxx", "yyy" }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 159)
            .HasMessage("Expecting contains elements:\n"
                            + "  [aaa, bbb, ccc, ddd, eee]\n"
                            + " do contains (in any order)\n"
                            + "  [bbb, xxx, yyy]\n"
                            + " but could not find elements:\n"
                            + "  [xxx, yyy]");
    }

    [TestCase]
    public void Contains_stringsAsElements()
    {
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).Contains();
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).Contains("ddd", "bbb");
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).Contains("eee", "ddd", "ccc", "bbb", "aaa");
        // should fail because the array not contains 7 and 6
        AssertThrown(() => AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).Contains("bbb", "xxx", "yyy"))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 177)
            .HasMessage("Expecting contains elements:\n"
                            + "  [aaa, bbb, ccc, ddd, eee]\n"
                            + " do contains (in any order)\n"
                            + "  [bbb, xxx, yyy]\n"
                            + " but could not find elements:\n"
                            + "  [xxx, yyy]");
    }

    [TestCase]
    public void Contains_numbersAsArray()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(new int[] { });
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(new int[] { 5, 2 });
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(new int[] { 5, 4, 3, 2, 1 });
        // should fail because the array not contains 7 and 6
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(new int[] { 2, 7, 6 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 195)
            .HasMessage("Expecting contains elements:\n"
                            + "  [1, 2, 3, 4, 5]\n"
                            + " do contains (in any order)\n"
                            + "  [2, 7, 6]\n"
                            + " but could not find elements:\n"
                            + "  [7, 6]");
    }

    [TestCase]
    public void Contains_numbersAsElements()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains();
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(5, 2);
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(5, 4, 3, 2, 1);
        // should fail because the array not contains 7 and 6
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(2, 7, 6))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 213)
            .HasMessage("Expecting contains elements:\n"
                            + "  [1, 2, 3, 4, 5]\n"
                            + " do contains (in any order)\n"
                            + "  [2, 7, 6]\n"
                            + " but could not find elements:\n"
                            + "  [7, 6]");
    }

    [TestCase]
    public void ContainsExactly_stringsAsArray()
    {
        // test agains only one element
        AssertArray(new string[] { "abc" }).ContainsExactly(new string[] { "abc" });
        AssertThrown(() => AssertArray(new string[] { "abc" }).ContainsExactly(new string[] { "abXc" }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 229)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [abc]\n"
                            + " do contains (in same order)\n"
                            + "  [abXc]\n"
                            + " but some elements where not expected:\n"
                            + "  [abc]\n"
                            + " and could not find elements:\n"
                            + "  [abXc]");

        // test agains many elements
        AssertArray(new string[] { "abc", "def", "xyz" }).ContainsExactly(new string[] { "abc", "def", "xyz" });
        // should fail because if contains the same elements but in a different order
        AssertThrown(() => AssertArray(new string[] { "abc", "def", "xyz" }).ContainsExactly(new string[] { "abc", "xyz", "def" }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 244)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [abc, def, xyz]\n"
                            + " do contains (in same order)\n"
                            + "  [abc, xyz, def]\n"
                            + " but has different order at position '1'\n"
                            + " 'def' vs 'xyz'");

        // should fail because it contains more elements and in a different order
        AssertThrown(() => AssertArray(new string[] { "abc", "def", "foo", "bar", "xyz" }).ContainsExactly(new string[] { "abc", "xyz", "def" }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 255)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [abc, def, foo, bar, xyz]\n"
                            + " do contains (in same order)\n"
                            + "  [abc, xyz, def]\n"
                            + " but some elements where not expected:\n"
                            + "  [foo, bar]");

        // should fail because it contains less elements and in a different order
        AssertThrown(() => AssertArray(new string[] { "abc", "def", "xyz" }).ContainsExactly(new string[] { "abc", "def", "bar", "foo", "xyz" }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 266)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [abc, def, xyz]\n"
                            + " do contains (in same order)\n"
                            + "  [abc, def, bar, foo, xyz]\n"
                            + " but could not find elements:\n"
                            + "  [bar, foo]");
    }

    [TestCase]
    public void ContainsExactly_stringsAsElements()
    {
        // test agains only one element
        AssertArray(new string[] { "abc" }).ContainsExactly("abc");
        AssertThrown(() => AssertArray(new string[] { "abc" }).ContainsExactly("abXc"))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 282)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [abc]\n"
                            + " do contains (in same order)\n"
                            + "  [abXc]\n"
                            + " but some elements where not expected:\n"
                            + "  [abc]\n"
                            + " and could not find elements:\n"
                            + "  [abXc]");

        // test agains many elements
        AssertArray(new string[] { "abc", "def", "xyz" }).ContainsExactly("abc", "def", "xyz");
        // should fail because if contains the same elements but in a different order
        AssertThrown(() => AssertArray(new string[] { "abc", "def", "xyz" }).ContainsExactly("abc", "xyz", "def"))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 297)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [abc, def, xyz]\n"
                            + " do contains (in same order)\n"
                            + "  [abc, xyz, def]\n"
                            + " but has different order at position '1'\n"
                            + " 'def' vs 'xyz'");

        // should fail because it contains more elements and in a different order
        AssertThrown(() => AssertArray(new string[] { "abc", "def", "foo", "bar", "xyz" }).ContainsExactly("abc", "xyz", "def"))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 308)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [abc, def, foo, bar, xyz]\n"
                            + " do contains (in same order)\n"
                            + "  [abc, xyz, def]\n"
                            + " but some elements where not expected:\n"
                            + "  [foo, bar]");

        // should fail because it contains less elements and in a different order
        AssertThrown(() => AssertArray(new string[] { "abc", "def", "xyz" }).ContainsExactly("abc", "def", "bar", "foo", "xyz"))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 319)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [abc, def, xyz]\n"
                            + " do contains (in same order)\n"
                            + "  [abc, def, bar, foo, xyz]\n"
                            + " but could not find elements:\n"
                            + "  [bar, foo]");
    }

    [TestCase]
    public void ContainsExactly_numbersAsArray()
    {
        // test agains array with only one element
        AssertArray(new int[] { 1 }).ContainsExactly(new int[] { 1 });
        AssertThrown(() => AssertArray(new int[] { 1 }).ContainsExactly(new int[] { 2 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 335)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1]\n"
                            + " do contains (in same order)\n"
                            + "  [2]\n"
                            + " but some elements where not expected:\n"
                            + "  [1]\n"
                            + " and could not find elements:\n"
                            + "  [2]");

        // test agains array with many elements
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(new int[] { 1, 2, 3, 4, 5 });
        // should fail because if contains the same elements but in a different order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(new int[] { 1, 4, 3, 2, 5 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 350)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 3, 4, 5]\n"
                            + " do contains (in same order)\n"
                            + "  [1, 4, 3, 2, 5]\n"
                            + " but has different order at position '1'\n"
                            + " '2' vs '4'");

        // should fail because it contains more elements and in a different order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5, 6, 7 }).ContainsExactly(new int[] { 1, 4, 3, 2, 5 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 361)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 3, 4, 5, 6, 7]\n"
                            + " do contains (in same order)\n"
                            + "  [1, 4, 3, 2, 5]\n"
                            + " but some elements where not expected:\n"
                            + "  [6, 7]");

        // should fail because it contains less elements and in a different order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(new int[] { 1, 4, 3, 2, 5, 6, 7 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 372)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 3, 4, 5]\n"
                            + " do contains (in same order)\n"
                            + "  [1, 4, 3, 2, 5, 6, 7]\n"
                            + " but could not find elements:\n"
                            + "  [6, 7]");
    }

    [TestCase]
    public void ContainsExactly_numbersAsElements()
    {
        // test agains array with only one element
        AssertArray(new int[] { 1 }).ContainsExactly(1);
        AssertThrown(() => AssertArray(new int[] { 1 }).ContainsExactly(2))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 388)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1]\n"
                            + " do contains (in same order)\n"
                            + "  [2]\n"
                            + " but some elements where not expected:\n"
                            + "  [1]\n"
                            + " and could not find elements:\n"
                            + "  [2]");

        // test agains array with many elements
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(1, 2, 3, 4, 5);
        // should fail because if contains the same elements but in a different order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(1, 4, 3, 2, 5))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 403)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 3, 4, 5]\n"
                            + " do contains (in same order)\n"
                            + "  [1, 4, 3, 2, 5]\n"
                            + " but has different order at position '1'\n"
                            + " '2' vs '4'");

        // should fail because it contains more elements and in a different order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5, 6, 7 }).ContainsExactly(1, 4, 3, 2, 5))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 414)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 3, 4, 5, 6, 7]\n"
                            + " do contains (in same order)\n"
                            + "  [1, 4, 3, 2, 5]\n"
                            + " but some elements where not expected:\n"
                            + "  [6, 7]");

        // should fail because it contains less elements and in a different order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(1, 4, 3, 2, 5, 6, 7))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 425)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 3, 4, 5]\n"
                            + " do contains (in same order)\n"
                            + "  [1, 4, 3, 2, 5, 6, 7]\n"
                            + " but could not find elements:\n"
                            + "  [6, 7]");
    }

    [TestCase]
    public void ContainsExactlyInAnyOrder_stringsAsArray()
    {
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).ContainsExactlyInAnyOrder(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" });
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).ContainsExactlyInAnyOrder(new string[] { "eee", "ddd", "ccc", "bbb", "aaa" });
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).ContainsExactlyInAnyOrder(new string[] { "bbb", "aaa", "ccc", "eee", "ddd" });

        // should fail because is contains not exactly the same elements in any order
        AssertThrown(() => AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd" })
                .ContainsExactlyInAnyOrder(new string[] { "xxx", "aaa", "yyy", "bbb", "ccc", "ddd" }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 444)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [aaa, bbb, ccc, ddd]\n"
                            + " do contains (in any order)\n"
                            + "  [xxx, aaa, yyy, bbb, ccc, ddd]\n"
                            + " but could not find elements:\n"
                            + "  [xxx, yyy]");

        //should fail because is contains the same elements but in a different order
        AssertThrown(() => AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee", "fff" })
                .ContainsExactlyInAnyOrder(new string[] { "fff", "aaa", "ddd", "bbb", "eee", }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 456)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [aaa, bbb, ccc, ddd, eee, fff]\n"
                            + " do contains (in any order)\n"
                            + "  [fff, aaa, ddd, bbb, eee]\n"
                            + " but some elements where not expected:\n"
                            + "  [ccc]");
    }

    [TestCase]
    public void ContainsExactlyInAnyOrder_stringsAsElements()
    {
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).ContainsExactlyInAnyOrder("aaa", "bbb", "ccc", "ddd", "eee");
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).ContainsExactlyInAnyOrder("eee", "ddd", "ccc", "bbb", "aaa");
        AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee" }).ContainsExactlyInAnyOrder("bbb", "aaa", "ccc", "eee", "ddd");

        // should fail because is contains not exactly the same elements in any order
        AssertThrown(() => AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd" })
                .ContainsExactlyInAnyOrder("xxx", "aaa", "yyy", "bbb", "ccc", "ddd"))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 476)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [aaa, bbb, ccc, ddd]\n"
                            + " do contains (in any order)\n"
                            + "  [xxx, aaa, yyy, bbb, ccc, ddd]\n"
                            + " but could not find elements:\n"
                            + "  [xxx, yyy]");

        //should fail because is contains the same elements but in a different order
        AssertThrown(() => AssertArray(new string[] { "aaa", "bbb", "ccc", "ddd", "eee", "fff" })
                .ContainsExactlyInAnyOrder("fff", "aaa", "ddd", "bbb", "eee"))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 488)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [aaa, bbb, ccc, ddd, eee, fff]\n"
                            + " do contains (in any order)\n"
                            + "  [fff, aaa, ddd, bbb, eee]\n"
                            + " but some elements where not expected:\n"
                            + "  [ccc]");
    }

    [TestCase]
    public void ContainsExactlyInAnyOrder_numbersAsArray()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(new int[] { 1, 2, 3, 4, 5 });
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(new int[] { 5, 3, 2, 4, 1 });
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(new int[] { 5, 1, 2, 4, 3 });

        // should fail because is contains not exactly the same elements in any order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 6, 4, 5 }).ContainsExactlyInAnyOrder(new int[] { 5, 3, 2, 4, 1, 9, 10 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 508)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 6, 4, 5]\n"
                            + " do contains (in any order)\n"
                            + "  [5, 3, 2, 4, 1, 9, 10]\n"
                            + " but some elements where not expected:\n"
                            + "  [6]\n"
                            + " and could not find elements:\n"
                            + "  [3, 9, 10]");

        //should fail because is contains the same elements but in a different order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 6, 9, 10, 4, 5 }).ContainsExactlyInAnyOrder(new int[] { 5, 3, 2, 4, 1 }))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 521)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 6, 9, 10, 4, 5]\n"
                            + " do contains (in any order)\n"
                            + "  [5, 3, 2, 4, 1]\n"
                            + " but some elements where not expected:\n"
                            + "  [6, 9, 10]\n"
                            + " and could not find elements:\n"
                            + "  [3]");
    }

    [TestCase]
    public void ContainsExactlyInAnyOrder_numbersAsElements()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(1, 2, 3, 4, 5);
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(5, 3, 2, 4, 1);
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(5, 1, 2, 4, 3);

        // should fail because is contains not exactly the same elements in any order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 6, 4, 5 }).ContainsExactlyInAnyOrder(5, 3, 2, 4, 1, 9, 10))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 542)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 6, 4, 5]\n"
                            + " do contains (in any order)\n"
                            + "  [5, 3, 2, 4, 1, 9, 10]\n"
                            + " but some elements where not expected:\n"
                            + "  [6]\n"
                            + " and could not find elements:\n"
                            + "  [3, 9, 10]");

        //should fail because is contains the same elements but in a different order
        AssertThrown(() => AssertArray(new int[] { 1, 2, 6, 9, 10, 4, 5 }).ContainsExactlyInAnyOrder(5, 3, 2, 4, 1))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 555)
            .HasMessage("Expecting contains exactly elements:\n"
                            + "  [1, 2, 6, 9, 10, 4, 5]\n"
                            + " do contains (in any order)\n"
                            + "  [5, 3, 2, 4, 1]\n"
                            + " but some elements where not expected:\n"
                            + "  [6, 9, 10]\n"
                            + " and could not find elements:\n"
                            + "  [3]");
    }

    [TestCase]
    public void Fluent()
    {
        AssertArray(new int[] { })
            .Contains(new int[] { })
            .ContainsExactly(new int[] { })
            .HasSize(0)
            .IsEmpty()
            .IsNotNull();
    }

    [TestCase]
    public void Extract()
    {
        // try to extract on base types
        AssertArray(new object[] { 1, false, 3.14, null, Colors.AliceBlue }).Extract("GetClass")
            .ContainsExactly("n.a.", "n.a.", "n.a.", null, "n.a.");
        // extracting by a func without arguments
        AssertArray(new object[] { new Reference(), 2, new AStar(), AutoFree(new Node()) }).Extract("GetClass")
            .ContainsExactly("Reference", "n.a.", "AStar", "Node");
        // extracting by a func with arguments
        AssertArray(new object[] { new Reference(), 2, new AStar(), AutoFree(new Node()) }).Extract("HasSignal", new object[] { "tree_entered" })
            .ContainsExactly(false, "n.a.", false, true);

        // try extract on object via a func that not exists
        AssertArray(new object[] { new Reference(), 2, new AStar(), AutoFree(new Node()) }).Extract("InvalidMethod")
            .ContainsExactly("n.a.", "n.a.", "n.a.", "n.a.");
        // try extract on object via a func that has no return value
        AssertArray(new object[] { new Reference(), 2, new AStar(), AutoFree(new Node()) }).Extract("RemoveMeta", new object[] { "" })
            .ContainsExactly(null, "n.a.", null, null);
    }

    class TestObj : Godot.Reference
    {
        string _name;
        object _value;
        object _x;

        public TestObj(string name, object value, object x = null)
        {
            _name = name;
            _value = value;
            _x = x;
        }

        public string GetName() => _name;
        public object GetValue() => _value;
        public object GetX() => _x;
        public string GetX1() => "x1";
        public string GetX2() => "x2";
        public string GetX3() => "x3";
        public string GetX4() => "x4";
        public string GetX5() => "x5";
        public string GetX6() => "x6";
        public string GetX7() => "x7";
        public string GetX8() => "x8";
        public string GetX9() => "x9";
    }

    [TestCase]
    public void ExtractV()
    {
        // single extract
        AssertArray(new object[] { 1, false, 3.14, null, Colors.AliceBlue })
            .ExtractV(Extr("GetClass"))
            .ContainsExactly("n.a.", "n.a.", "n.a.", null, "n.a.");
        // tuple of two
        AssertArray(new object[] { new TestObj("A", 10), new TestObj("B", "foo"), Colors.AliceBlue, new TestObj("C", 11) })
            .ExtractV(Extr("GetName"), Extr("GetValue"))
            .ContainsExactly(Tuple("A", 10), Tuple("B", "foo"), Tuple("n.a.", "n.a."), Tuple("C", 11));
        // tuple of three
        AssertArray(new object[] { new TestObj("A", 10), new TestObj("B", "foo", "bar"), new TestObj("C", 11, 42) })
            .ExtractV(Extr("GetName"), Extr("GetValue"), Extr("GetX"))
            .ContainsExactly(Tuple("A", 10, null), Tuple("B", "foo", "bar"), Tuple("C", 11, 42));
    }

    [TestCase]
    public void ExtractV_Chained()
    {
        var root_a = new TestObj("root_a", null);
        var obj_a = new TestObj("A", root_a);
        var obj_b = new TestObj("B", root_a);
        var obj_c = new TestObj("C", root_a);
        var root_b = new TestObj("root_b", root_a);
        var obj_x = new TestObj("X", root_b);
        var obj_y = new TestObj("Y", root_b);

        AssertArray(new object[] { obj_a, obj_b, obj_c, obj_x, obj_y })
            .ExtractV(Extr("GetName"), Extr("GetValue.GetName"))
            .ContainsExactly(
                Tuple("A", "root_a"),
                Tuple("B", "root_a"),
                Tuple("C", "root_a"),
                Tuple("X", "root_b"),
                Tuple("Y", "root_b")
            );
    }

    [TestCase]
    public void Extract_Chained()
    {
        var root_a = new TestObj("root_a", null);
        var obj_a = new TestObj("A", root_a);
        var obj_b = new TestObj("B", root_a);
        var obj_c = new TestObj("C", root_a);
        var root_b = new TestObj("root_b", root_a);
        var obj_x = new TestObj("X", root_b);
        var obj_y = new TestObj("Y", root_b);

        AssertArray(new object[] { obj_a, obj_b, obj_c, obj_x, obj_y })
            .Extract("GetValue.GetName")
            .ContainsExactly(
                "root_a",
                "root_a",
                "root_a",
                "root_b",
                "root_b"
            );
    }

    [TestCase]
    public void Extract_InvalidMethod()
    {
        AssertArray(new object[] { "abc" })
            .Extract("NotExistMethod")
            .ContainsExactly("n.a.");
    }

    [TestCase]
    public void ExtractV_ManyArgs()
    {
        AssertArray(new object[] { new TestObj("A", 10), new TestObj("B", "foo", "bar"), new TestObj("C", 11, 42) })
            .ExtractV(
                Extr("GetName"),
                Extr("GetX1"),
                Extr("GetX2"),
                Extr("GetX3"),
                Extr("GetX4"),
                Extr("GetX5"),
                Extr("GetX6"),
                Extr("GetX7"),
                Extr("GetX8"),
                Extr("GetX9"))
            .ContainsExactly(
                Tuple("A", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9"),
                Tuple("B", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9"),
                Tuple("C", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9"));
    }

    [TestCase]
    public void OverrideFailureMessage()
    {
        AssertThrown(() => AssertArray(new object[] { })
                .OverrideFailureMessage("Custom failure message")
                .IsNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 720)
            .HasMessage("Custom failure message");
    }

    [TestCase]
    public void Interrupt_IsFailure()
    {
        // we disable failure reportion until we simmulate an failure
        ExecutionContext.Current.FailureReporting = false;
        // try to fail
        AssertArray(new object[] { }).IsNotEmpty();
        ExecutionContext.Current.FailureReporting = true;

        // expect this line will never called because of the test is interrupted by a failing assert
        AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
    }
}
