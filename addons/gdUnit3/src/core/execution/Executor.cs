using System.Collections.Generic;

namespace GdUnit3
{
    public sealed class Executor : Godot.Reference
    {

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

        public void execute(TestSuite testSuite)
        {
            var stage = new TestSuiteExecutionStage(testSuite.GetType());
            stage.Execute(new ExecutionContext(testSuite, _eventListeners));
            testSuite.Free();
        }
    }
}
