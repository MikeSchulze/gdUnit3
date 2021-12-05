using GdUnit3;
using Godot;

using static GdUnit3.Assertions;
using static GdUnit3.Assertions.EXPECT;

[TestSuite]
public class ArrayAssertTest : TestSuite
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
        AssertArray(new object[] { new Reference(), 2, new AStar(), AutoFree(new Node()) }).Extract("get_class")
            .ContainsExactly(new object[] { "Reference", "n.a.", "AStar", "Node" });
        // extracting by a func with arguments
        AssertArray(new object[] { new Reference(), 2, new AStar(), AutoFree(new Node()) }).Extract("has_signal", new object[] { "tree_entered" })
            .ContainsExactly(new object[] { false, "n.a.", false, true });

        // try extract on object via a func that not exists
        AssertArray(new object[] { new Reference(), 2, new AStar(), AutoFree(new Node()) }).Extract("invalid_func")
            .ContainsExactly(new object[] { "n.a.", "n.a.", "n.a.", "n.a." });
        // try extract on object via a func that has no return value
        AssertArray(new object[] { new Reference(), 2, new AStar(), AutoFree(new Node()) }).Extract("remove_meta", new object[] { "" })
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
            .ContainsExactly(new object[] { "n.a.", "n.a.", "n.a.", null, "n.a." });
        // tuple of two
        AssertArray(new object[] { new TestObj("A", 10), new TestObj("B", "foo"), Colors.AliceBlue, new TestObj("C", 11) })
            .ExtractV(Extr("GetName"), Extr("GetValue"))
            .ContainsExactly(new object[] { Tuple("A", 10), Tuple("B", "foo"), Tuple("n.a.", "n.a."), Tuple("C", 11) });
        // tuple of three
        AssertArray(new object[] { new TestObj("A", 10), new TestObj("B", "foo", "bar"), new TestObj("C", 11, 42) })
            .ExtractV(Extr("GetName"), Extr("GetValue"), Extr("GetX"))
            .ContainsExactly(new object[] { Tuple("A", 10, null), Tuple("B", "foo", "bar"), Tuple("C", 11, 42) });
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
            .ContainsExactly(new object[]{
                Tuple("A", "root_a"),
                Tuple("B", "root_a"),
                Tuple("C", "root_a"),
                Tuple("X", "root_b"),
                Tuple("Y", "root_b")
            });
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
            .ContainsExactly(new object[]{
                "root_a",
                "root_a",
                "root_a",
                "root_b",
                "root_b"
            });
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
            .ContainsExactly(new object[]{
                Tuple("A", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9"),
                Tuple("B", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9"),
                Tuple("C", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9")});
    }

    [TestCase]
    public void OverrideFailureMessage()
    {
        AssertArray(new object[] { }, FAIL)
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
        AssertArray(new object[] { }, FAIL).IsNotEmpty();

        // expect this line will never called because of the test is interrupted by a failing assert
        AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
    }
}
