// GdUnit generated TestSuite
using Godot;
using GdUnit3;
using System;

namespace GdUnit3
{
	using static Assertions;
	using static Utils;

	[TestSuite]
	public class GdUnit3MonoAPITest
	{
		// TestSuite generated from
		private const string sourceClazzPath = "d:/develop/workspace/gdUnit3/addons/gdUnit3/src/mono/GdUnit3MonoAPI.cs";
		[TestCase]
		public void IsTestSuite()
		{
			AssertThat(GdUnit3MonoAPI.IsTestSuite("res://addons/gdUnit3/src/mono/GdUnit3MonoAPI.cs")).IsFalse();
			AssertThat(GdUnit3MonoAPI.IsTestSuite("res://addons/gdUnit3/test/mono/GdUnit3MonoAPITest.cs")).IsTrue();
		}
	}
}
