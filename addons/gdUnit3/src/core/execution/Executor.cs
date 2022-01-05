using System.Collections.Generic;

namespace GdUnit3
{
    public sealed class Executor : Godot.Reference
    {

        public Executor()
        {
            ReportOrphanNodesEnabled = true;
        }

        private List<ITestEventListener> _eventListeners = new List<ITestEventListener>();

        private class GdTestEventListenerDelegator : ITestEventListener
        {
            private readonly Godot.Object _listener;

            public GdTestEventListenerDelegator(Godot.Object listener)
            {
                _listener = listener;
            }
            public void PublishEvent(TestEvent testEvent) => _listener.Call("PublishEvent", testEvent);
        }

        public void AddGdTestEventListener(Godot.Object listener)
        {
            // I want to using anonymus implementation to remove the extra delegator class
            _eventListeners.Add(new GdTestEventListenerDelegator(listener));
        }

        public void AddTestEventListener(ITestEventListener listener)
        {
            _eventListeners.Add(listener);
        }

        public bool ReportOrphanNodesEnabled { get; set; }

        public void Execute(TestSuite testSuite)
        {
            if (!ReportOrphanNodesEnabled)
                Godot.GD.PushWarning("!!! Reporting orphan nodes is disabled. Please check GdUnit settings.");
            try
            {
                using (ExecutionContext context = new ExecutionContext(testSuite, _eventListeners, ReportOrphanNodesEnabled))
                {
                    new TestSuiteExecutionStage(testSuite.GetType()).Execute(context);
                }
            }
            finally
            {
                testSuite.Free();
            }
        }
    }
}
