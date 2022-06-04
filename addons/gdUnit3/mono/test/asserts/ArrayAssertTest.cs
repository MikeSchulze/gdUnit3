using Godot;

namespace GdUnit3.Tests.Asserts
{
    using Executions;
    using Exceptions;
    using static Assertions;

    [TestSuite]
    public class ArrayAssertTest
    {
        [TestCase]
        public void IsNull()
        {
            AssertArray(null).IsNull();

            // should fail because the current is not null
            AssertThrown(() => AssertArray(new object[] { }).IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 18)
                .HasMessage("Expecting be <Null>:\n"
                    + " but is\n"
                    + "  System.Object[]");
            AssertThrown(() => AssertArray(new int[] { }).IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 24)
                .HasMessage("Expecting be <Null>:\n"
                    + " but is\n"
                    + "  System.Int32[]");
            // with godot array
            AssertThrown(() => AssertArray(new Godot.Collections.Array()).IsNull())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 31)
                .HasMessage("Expecting be <Null>:\n"
                    + " but is\n"
                    + "  Godot.Collections.Array[]");
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
                .HasPropertyValue("LineNumber", 48)
                .HasMessage("Expecting be NOT <Null>:");
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
                .HasPropertyValue("LineNumber", 64)
                .HasMessage("Expecting be equal:\n"
                    + "  System.Int32[1, 2, 3, 4, 2, 5]\n"
                    + " but is\n"
                    + "  System.Int32[1, 2, 4, 5]");
            AssertThrown(() => AssertArray(new Godot.Collections.Array(new int[] { 1, 2, 4, 5 })).IsEqual(new Godot.Collections.Array(new int[] { 1, 2, 3, 4, 2, 5 })))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 71)
                .HasMessage("Expecting be equal:\n"
                    + "  Godot.Collections.Array[1, 2, 3, 4, 2, 5]\n"
                    + " but is\n"
                    + "  Godot.Collections.Array[1, 2, 4, 5]");
            AssertThrown(() => AssertArray(null).IsEqual(new object[] { }))
               .IsInstanceOf<TestFailedException>()
               .HasPropertyValue("LineNumber", 78)
               .HasMessage("Expecting be equal:\n"
                   + "  System.Object[]\n"
                   + " but is\n"
                   + "  <Null>");
        }

        [TestCase]
        public void IsEqualIgnoringCase()
        {
            AssertArray(new string[] { "this", "is", "a", "message" }).IsEqualIgnoringCase(new string[] { "This", "is", "a", "Message" });
            // should fail because the array not contains same elements
            AssertThrown(() => AssertArray(new string[] { "this", "is", "a", "message" })
                    .IsEqualIgnoringCase(new string[] { "This", "is", "an", "Message" }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 92)
                .HasMessage("Expecting be equal (ignoring case):\n"
                    + "  System.String[This, is, an, Message]\n"
                    + " but is\n"
                    + "  System.String[this, is, a, message]");
            AssertThrown(() => AssertArray(null)
                   .IsEqualIgnoringCase(new string[] { "This", "is" }))
               .IsInstanceOf<TestFailedException>()
               .HasPropertyValue("LineNumber", 100)
               .HasMessage("Expecting be equal (ignoring case):\n"
                   + "  System.String[This, is]\n"
                   + " but is\n"
                   + "  <Null>");
        }

        [TestCase]
        public void IsNotEqual()
        {
            AssertArray(null).IsNotEqual(new int[] { 1, 2, 3, 4, 5 });
            AssertArray(new int[] { 1, 2, 3, 4, 5 }).IsNotEqual(new int[] { 1, 2, 3, 4, 5, 6 });
            // should fail because the array  contains same elements
            AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).IsNotEqual(new int[] { 1, 2, 3, 4, 5 }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 116)
                .HasMessage("Expecting be NOT equal:\n"
                    + "  System.Int32[1, 2, 3, 4, 5]\n"
                    + " but is\n"
                    + "  System.Int32[1, 2, 3, 4, 5]");
        }

        [TestCase]
        public void IsNotEqualIgnoringCase()
        {
            AssertArray(null).IsNotEqualIgnoringCase(new string[] { "This", "is", "an", "Message" });
            AssertArray(new string[] { "this", "is", "a", "message" }).IsNotEqualIgnoringCase(new string[] { "This", "is", "an", "Message" });
            // should fail because the array contains same elements ignoring case sensitive
            AssertThrown(() => AssertArray(new string[] { "this", "is", "a", "message" })
                    .IsNotEqualIgnoringCase(new string[] { "This", "is", "a", "Message" }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 131)
                .HasMessage("Expecting be NOT equal (ignoring case):\n"
                    + "  System.String[This, is, a, Message]\n"
                    + " but is\n"
                    + "  System.String[this, is, a, message]");
        }

        [TestCase]
        public void IsEmpty()
        {
            AssertArray(new int[] { }).IsEmpty();
            // should fail because the array is not empty it has a size of one
            AssertThrown(() => AssertArray(new int[] { 1 }).IsEmpty())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 146)
                .HasMessage("Expecting be empty:\n but has size '1'");
            AssertThrown(() => AssertArray(null).IsEmpty())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 150)
                .HasMessage("Expecting be empty:\n but is <Null>");
        }

        [TestCase]
        public void IsNotEmpty()
        {
            AssertArray(null).IsNotEmpty();
            AssertArray(new int[] { 1 }).IsNotEmpty();
            // should fail because the array is empty
            AssertThrown(() => AssertArray(new int[] { }).IsNotEmpty())
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 162)
                .HasMessage("Expecting being NOT empty:\n but is empty");
        }

        [TestCase]
        public void HasSize()
        {
            AssertArray(new int[] { 1, 2, 3, 4, 5 }).HasSize(5);
            AssertArray(new string[] { "a", "b", "c", "d", "e", "f" }).HasSize(6);
            // should fail because the array has a size of 5
            AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).HasSize(4))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 174)
                .HasMessage("Expecting size:\n  '4' but is '5'");
            AssertThrown(() => AssertArray(null).HasSize(4))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 178)
                .HasMessage("Expecting size:\n  '4' but is 'unknown'");
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
                .HasPropertyValue("LineNumber", 191)
                .HasMessage("Expecting contains elements:\n"
                            + "  [aaa, bbb, ccc, ddd, eee]\n"
                            + " do contains (in any order)\n"
                            + "  [bbb, xxx, yyy]\n"
                            + " but could not find elements:\n"
                            + "  [xxx, yyy]");
            AssertThrown(() => AssertArray(null).Contains(new string[] { "bbb", "xxx", "yyy" }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 200)
                .HasMessage("Expecting contains elements:\n"
                            + "  <Null>\n"
                            + " do contains (in any order)\n"
                            + "  [bbb, xxx, yyy]\n"
                            + " but could not find elements:\n"
                            + "  [bbb, xxx, yyy]");
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
                .HasPropertyValue("LineNumber", 218)
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
                .HasPropertyValue("LineNumber", 236)
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
                .HasPropertyValue("LineNumber", 254)
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
                .HasPropertyValue("LineNumber", 270)
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
                .HasPropertyValue("LineNumber", 285)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [abc, def, xyz]\n"
                                + " do contains (in same order)\n"
                                + "  [abc, xyz, def]\n"
                                + " but has different order at position '1'\n"
                                + "  'def' vs 'xyz'");

            // should fail because it contains more elements and in a different order
            AssertThrown(() => AssertArray(new string[] { "abc", "def", "foo", "bar", "xyz" }).ContainsExactly(new string[] { "abc", "xyz", "def" }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 296)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [abc, def, foo, bar, xyz]\n"
                                + " do contains (in same order)\n"
                                + "  [abc, xyz, def]\n"
                                + " but some elements where not expected:\n"
                                + "  [foo, bar]");

            // should fail because it contains less elements and in a different order
            AssertThrown(() => AssertArray(new string[] { "abc", "def", "xyz" }).ContainsExactly(new string[] { "abc", "def", "bar", "foo", "xyz" }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 307)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [abc, def, xyz]\n"
                                + " do contains (in same order)\n"
                                + "  [abc, def, bar, foo, xyz]\n"
                                + " but could not find elements:\n"
                                + "  [bar, foo]");
            AssertThrown(() => AssertArray(null).ContainsExactly(new string[] { "abc", "def", "bar", "foo", "xyz" }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 316)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  <Null>\n"
                                + " do contains (in same order)\n"
                                + "  [abc, def, bar, foo, xyz]\n"
                                + " but could not find elements:\n"
                                + "  [abc, def, bar, foo, xyz]");
        }

        [TestCase]
        public void ContainsExactly_stringsAsElements()
        {
            // test agains only one element
            AssertArray(new string[] { "abc" }).ContainsExactly("abc");
            AssertThrown(() => AssertArray(new string[] { "abc" }).ContainsExactly("abXc"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 332)
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
                .HasPropertyValue("LineNumber", 346)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [abc, def, xyz]\n"
                                + " do contains (in same order)\n"
                                + "  [abc, xyz, def]\n"
                                + " but has different order at position '1'\n"
                                + "  'def' vs 'xyz'");
            // should fail because it contains more elements and in a different order
            AssertThrown(() => AssertArray(new string[] { "abc", "def", "foo", "bar", "xyz" }).ContainsExactly("abc", "xyz", "def"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 356)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [abc, def, foo, bar, xyz]\n"
                                + " do contains (in same order)\n"
                                + "  [abc, xyz, def]\n"
                                + " but some elements where not expected:\n"
                                + "  [foo, bar]");
            // should fail because it contains less elements and in a different order
            AssertThrown(() => AssertArray(new string[] { "abc", "def", "xyz" }).ContainsExactly("abc", "def", "bar", "foo", "xyz"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 366)
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
                .HasPropertyValue("LineNumber", 382)
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
                .HasPropertyValue("LineNumber", 396)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [1, 2, 3, 4, 5]\n"
                                + " do contains (in same order)\n"
                                + "  [1, 4, 3, 2, 5]\n"
                                + " but has different order at position '1'\n"
                                + "  '2' vs '4'");
            // should fail because it contains more elements and in a different order
            AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5, 6, 7 }).ContainsExactly(new int[] { 1, 4, 3, 2, 5 }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 406)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [1, 2, 3, 4, 5, 6, 7]\n"
                                + " do contains (in same order)\n"
                                + "  [1, 4, 3, 2, 5]\n"
                                + " but some elements where not expected:\n"
                                + "  [6, 7]");
            // should fail because it contains less elements and in a different order
            AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(new int[] { 1, 4, 3, 2, 5, 6, 7 }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 416)
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
                .HasPropertyValue("LineNumber", 432)
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
                .HasPropertyValue("LineNumber", 446)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [1, 2, 3, 4, 5]\n"
                                + " do contains (in same order)\n"
                                + "  [1, 4, 3, 2, 5]\n"
                                + " but has different order at position '1'\n"
                                + "  '2' vs '4'");
            // should fail because it contains more elements and in a different order
            AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5, 6, 7 }).ContainsExactly(1, 4, 3, 2, 5))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 456)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [1, 2, 3, 4, 5, 6, 7]\n"
                                + " do contains (in same order)\n"
                                + "  [1, 4, 3, 2, 5]\n"
                                + " but some elements where not expected:\n"
                                + "  [6, 7]");
            // should fail because it contains less elements and in a different order
            AssertThrown(() => AssertArray(new int[] { 1, 2, 3, 4, 5 }).ContainsExactly(1, 4, 3, 2, 5, 6, 7))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 466)
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
                .HasPropertyValue("LineNumber", 485)
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
                .HasPropertyValue("LineNumber", 496)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  [aaa, bbb, ccc, ddd, eee, fff]\n"
                                + " do contains (in any order)\n"
                                + "  [fff, aaa, ddd, bbb, eee]\n"
                                + " but some elements where not expected:\n"
                                + "  [ccc]");
            AssertThrown(() => AssertArray(null)
                    .ContainsExactlyInAnyOrder(new string[] { "fff", "aaa", "ddd", "bbb", "eee", }))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 506)
                .HasMessage("Expecting contains exactly elements:\n"
                                + "  <Null>\n"
                                + " do contains (in any order)\n"
                                + "  [fff, aaa, ddd, bbb, eee]\n"
                                + " but could not find elements:\n"
                                + "  [fff, aaa, ddd, bbb, eee]");
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
                .HasPropertyValue("LineNumber", 526)
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
                .HasPropertyValue("LineNumber", 537)
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
                .HasPropertyValue("LineNumber", 557)
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
                .HasPropertyValue("LineNumber", 569)
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
                .HasPropertyValue("LineNumber", 590)
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
                .HasPropertyValue("LineNumber", 602)
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
            AssertArray(new object?[] { 1, false, 3.14, null, Colors.AliceBlue }).Extract("GetClass")
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
            // must fail we can't extract from a null instance
            AssertThrown(() => AssertArray(null).Extract("GetClass").ContainsExactly("AStar", "Node"))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 646)
                .HasMessage("Expecting contains exactly elements:\n"
                    + "  <Null>\n"
                    + " do contains (in same order)\n"
                    + "  [AStar, Node]\n"
                    + " but could not find elements:\n"
                    + "  [AStar, Node]");
        }

        class TestObj : Godot.Reference
        {
            string _name;
            object? _value;
            object? _x;

            public TestObj(string name, object? value, object? x = null)
            {
                _name = name;
                _value = value;
                _x = x;
            }

            public string GetName() => _name;
            public object? GetValue() => _value;
            public object? GetX() => _x;
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
            AssertArray(new object?[] { 1, false, 3.14, null, Colors.AliceBlue })
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
            AssertThrown(() => AssertArray(null)
                    .ExtractV(Extr("GetName"), Extr("GetValue"), Extr("GetX"))
                    .ContainsExactly(Tuple("A", 10, null)))
                .IsInstanceOf<TestFailedException>()
                .HasPropertyValue("LineNumber", 699)
                .HasMessage("Expecting contains exactly elements:\n"
                    + "  <Null>\n"
                    + " do contains (in same order)\n"
                    + "  [tuple(A, 10, Null)]\n"
                    + " but could not find elements:\n"
                    + "  [tuple(A, 10, Null)]");
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
                .HasPropertyValue("LineNumber", 788)
                .HasMessage("Custom failure message");
        }

        [TestCase]
        public void Interrupt_IsFailure()
        {
            // we disable failure reportion until we simmulate an failure
            if (ExecutionContext.Current != null)
                ExecutionContext.Current.FailureReporting = false;
            // try to fail
            AssertArray(new object[] { }).IsNotEmpty();

            // expect this line will never called because of the test is interrupted by a failing assert
            AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
        }
    }
}
