using System.Diagnostics;

namespace GdUnit3.Exceptions
{
    internal sealed class TestFailedException : System.Exception
    {
        public TestFailedException(string message, int frameOffset = 0) : base(message)
        {
            StackFrame CallStack = new StackFrame(3 + frameOffset, true);
            LineNumber = CallStack.GetFileLineNumber();
        }

        public int LineNumber
        { get; private set; }
    }
}
