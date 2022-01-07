using System;

namespace GdUnit3
{
    public class TestStageAttribute : Attribute
    {
        /// <summary>
        /// Describes the intention of the test, will be shown as a tool tip on the inspector node.
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// The line of the annotated method
        /// </summary>
        internal int Line { get; set; }

        /// <summary>
        /// The name of the annotated method
        /// </summary>
        internal string Name { get; set; }
    }
}
