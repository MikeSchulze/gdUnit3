using System.Diagnostics;

namespace GdUnit3
{
    public sealed class TestFailedException : System.Exception
    {

        public TestFailedException(string message, int frame = 4) : base(message)
        {
            StackFrame CallStack = new StackFrame(frame, true);
            LineNumber = CallStack.GetFileLineNumber();
        }

        public int LineNumber
        { get; private set; }
    }
}
