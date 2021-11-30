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

    [TestCase]
    public void HasSize()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).HasSize(5);
        AssertArray(new string[] { "a", "b", "c", "d", "e", "f" }).HasSize(6);
        // should fail because the array has a size of 5
        AssertArray(new int[] { 1, 2, 3, 4, 5 }, FAIL).HasSize(4)
            .HasFailureMessage("Expecting size:\n '4'\n but was\n '5'");
    }

    [TestCase]
    public void Contains()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(new int[] { });
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(new int[] { 5, 2 });
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).Contains(new int[] { 5, 4, 3, 2, 1 });
        // should fail because the array not contains 7 and 6
        string expected_error_message = "Expecting contains elements:\n"
            + " 1, 2, 3, 4, 5\n"
            + " do contains (in any order)\n"
            + " 2, 7, 6\n"
            + "but could not find elements:\n"
            + " 7, 6";

        AssertArray(new int[] { 1, 2, 3, 4, 5 }, FAIL).Contains(new int[] { 2, 7, 6 })
            .HasFailureMessage(expected_error_message);
    }

    [TestCase]
    public void ContainsExactly()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(new int[] { 1, 2, 3, 4, 5 });
        // should fail because the array contains the same elements but in a different order
        string expected_error_message = "Expecting contains exactly elements:\n"
            + " 1, 2, 3, 4, 5\n"
            + " do contains (in same order)\n"
            + " 1, 4, 3, 2, 5\n"
            + " but has different order at position '1'\n"
            + " '2' vs '4'";

        AssertArray(new int[] { 1, 2, 3, 4, 5 }, FAIL)
            .ContainsExactly(new int[] { 1, 4, 3, 2, 5 })
            .HasFailureMessage(expected_error_message);

        // should fail because the array contains more elements and in a different order
        expected_error_message = "Expecting contains exactly elements:\n"
            + " 1, 2, 3, 4, 5, 6, 7\n"
            + " do contains (in same order)\n"
            + " 1, 4, 3, 2, 5\n"
            + "but some elements where not expected:\n"
            + " 6, 7";

        AssertArray(new int[] { 1, 2, 3, 4, 5, 6, 7 }, FAIL)
            .ContainsExactly(new int[] { 1, 4, 3, 2, 5 })
            .HasFailureMessage(expected_error_message);

        // should fail because the array contains less elements and in a different order
        expected_error_message = "Expecting contains exactly elements:\n"
            + " 1, 2, 3, 4, 5\n"
            + " do contains (in same order)\n"
            + " 1, 4, 3, 2, 5, 6, 7\n"
            + "but could not find elements:\n"
            + " 6, 7";

        AssertArray(new int[] { 1, 2, 3, 4, 5 }, FAIL)
            .ContainsExactly(new int[] { 1, 4, 3, 2, 5, 6, 7 })
            .HasFailureMessage(expected_error_message);
    }


    [TestCase]
    public void ContainsExactlyInAnyOrder()
    {
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(new int[] { 1, 2, 3, 4, 5 });
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(new int[] { 5, 3, 2, 4, 1 });
        AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactlyInAnyOrder(new int[] { 5, 1, 2, 4, 3 });

        // should fail because the array contains not exactly the same elements in any order
        string expected_error_message = "Expecting contains exactly elements:\n"
            + " 1, 2, 6, 4, 5\n"
            + " do contains exactly (in any order)\n"
            + " 5, 3, 2, 4, 1, 9, 10\n"
            + "but some elements where not expected:\n"
            + " 6\n"
            + "and could not find elements:\n"
            + " 3, 9, 10";

        AssertArray(new int[] { 1, 2, 6, 4, 5 }, FAIL)
            .ContainsExactlyInAnyOrder(new int[] { 5, 3, 2, 4, 1, 9, 10 })
            .HasFailureMessage(expected_error_message);

        //should fail because the array contains the same elements but in a different order
        expected_error_message = "Expecting contains exactly elements:\n"
            + " 1, 2, 6, 9, 10, 4, 5\n"
            + " do contains exactly (in any order)\n"
            + " 5, 3, 2, 4, 1\n"
            + "but some elements where not expected:\n"
            + " 6, 9, 10\n"
            + "and could not find elements:\n"
            + " 3";

        AssertArray(new int[] { 1, 2, 6, 9, 10, 4, 5 }, FAIL)
            .ContainsExactlyInAnyOrder(new int[] { 5, 3, 2, 4, 1 })
            .HasFailureMessage(expected_error_message);
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
        AssertArray(new object[] { 1, false, 3.14, null, Colors.AliceBlue }).Extract("get_class")
            .ContainsExactly(new object[] { "n.a.", "n.a.", "n.a.", null, "n.a." });
        // extracting by a func without arguments
        AssertArray(new object[] { new Reference(), 2, new AStar(), auto_free(new Node()) }).Extract("get_class")
            .ContainsExactly(new object[] { "Reference", "n.a.", "AStar", "Node" });
        // extracting by a func with arguments
        AssertArray(new object[] { new Reference(), 2, new AStar(), auto_free(new Node()) }).Extract("has_signal", new object[] { "tree_entered" })
            .ContainsExactly(new object[] { false, "n.a.", false, true });

        // try extract on object via a func that not exists
        AssertArray(new object[] { new Reference(), 2, new AStar(), auto_free(new Node()) }).Extract("invalid_func")
            .ContainsExactly(new object[] { "n.a.", "n.a.", "n.a.", "n.a." });
        // try extract on object via a func that has no return value
        AssertArray(new object[] { new Reference(), 2, new AStar(), auto_free(new Node()) }).Extract("remove_meta", new object[] { "" })
            .ContainsExactly(new object[] { null, "n.a.", null, null });
    }

    class TestObj
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

        public string getName() => _name;
        public object getValue() => _value;
        public object getX() => _x;
        public string getX1() => "x1";
        public string getX2() => "x2";
        public string getX3() => "x3";
        public string getX4() => "x4";
        public string getX5() => "x5";
        public string getX6() => "x6";
        public string getX7() => "x7";
        public string getX8() => "x8";
        public string getX9() => "x9";
    }

    [TestCase]
    public void ExtractV()
    {
        // single extract
        //  AssertArray(new object[] { 1, false, 3.14, null, Colors.AliceBlue })
        //    .ExtractV(extr("get_class"))
        //  .ContainsExactly(new object[] { "n.a.", "n.a.", "n.a.", null, "n.a." });
        // tuple of two
        //AssertArray(new object[] { new TestObj("A", 10), new TestObj("B", "foo"), Colors.AliceBlue, new TestObj("C", 11) })
        //  .ExtractV(extr("get_name"), extr("get_value"))
        //.ContainsExactly(new object[] { tuple("A", 10), tuple("B", "foo"), tuple("n.a.", "n.a."), tuple("C", 11) });
        // tuple of three
        //AssertArray(new object[] { new TestObj("A", 10), new TestObj("B", "foo", "bar"), new TestObj("C", 11, 42) })
        //  .ExtractV(extr("get_name"), extr("get_value"), extr("get_x"))
        // .ContainsExactly(new object[] { tuple("A", 10, null), tuple("B", "foo", "bar"), tuple("C", 11, 42) });
    }
}
