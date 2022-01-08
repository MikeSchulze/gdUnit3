using System;
using System.Linq;
using System.Collections.Generic;

namespace GdUnit3
{
    public sealed class TestReport
    {
        [Flags]
        public enum TYPE
        {
            SUCCESS,
            WARN,
            FAILURE,
            ORPHAN,
            TERMINATED,
            INTERUPTED,
            ABORT
        }

        public TestReport(TYPE type, int line_number, string message)
        {
            Type = type;
            LineNumber = line_number;
            Message = message;
        }

        public TYPE Type
        { get; private set; }

        public int LineNumber
        { get; private set; }

        public string Message
        { get; private set; }

        private static IEnumerable<TYPE> ErrorTypes => new[] { TYPE.TERMINATED, TYPE.INTERUPTED, TYPE.ABORT };

        public bool IsError => ErrorTypes.Contains(Type);

        public bool IsFailure => Type == TYPE.FAILURE;

        public bool IsWarning => Type == TYPE.WARN;

        public override string ToString() => $"[color=green]line [/color][color=aqua]{LineNumber}:[/color] \t {Message}";

        public IDictionary<string, object> Serialize()
        {
            return new Dictionary<string, object>(){
             {"type"        ,Type},
             {"line_number" ,LineNumber},
             {"message"     ,Message}
            };
        }

        public TestReport Deserialize(IDictionary<string, object> serialized)
        {
            TYPE type = (TYPE)Enum.Parse(typeof(TYPE), (string)serialized["type"]);
            int lineNumber = (int)serialized["line_number"];
            string message = (string)serialized["message"];
            return new TestReport(type, lineNumber, message);
        }
    }
}




