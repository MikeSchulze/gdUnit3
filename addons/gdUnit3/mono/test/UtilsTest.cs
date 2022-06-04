
using System.IO;

namespace GdUnit3.Tests
{
	using static Utils;
	using static Assertions;

	[TestSuite]
	public class UtilsTest
	{
		[TestCase]
		public void CreateTempDir_success()
		{
			string tempDir = CreateTempDir("foo");
			AssertThat(tempDir).IsEqual(Path.Combine(GodotTempDir(), "foo"));
			AssertThat(Directory.Exists(tempDir)).IsTrue();

			tempDir = CreateTempDir("bar1\\test\\foo");
			AssertThat(tempDir).IsEqual(Path.Combine(GodotTempDir(), "bar1\\test\\foo"));
			AssertThat(Directory.Exists(tempDir)).IsTrue();

			tempDir = CreateTempDir("bar2/test/foo");
			AssertThat(tempDir).IsEqual(Path.Combine(GodotTempDir(), "bar2/test/foo"));
			AssertThat(Directory.Exists(tempDir)).IsTrue();
		}

		[TestCase]
		public void CreateTempDir_atTwice()
		{
			string tempDir = CreateTempDir("foo");
			// create again
			CreateTempDir("foo");
			
			AssertThat(tempDir).IsEqual(Path.Combine(GodotTempDir(), "foo"));
			AssertThat(Directory.Exists(tempDir)).IsTrue();
		}

		[TestCase]
		public void ClearTempDir_success()
		{
			string tempDir = CreateTempDir("foo");
			AssertThat(Directory.Exists(tempDir)).IsTrue();

			ClearTempDir();
			AssertThat(Directory.Exists(tempDir)).IsFalse();
		}
	}
}
