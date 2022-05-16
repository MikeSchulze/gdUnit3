using System.Collections.Generic;
using System.Threading.Tasks;
using System;
using System.Linq;

namespace GdUnit3.Executions
{
    internal sealed class Executor : Godot.Reference
    {
        [Godot.Signal] private delegate void ExecutionCompleted();

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

        public bool ReportOrphanNodesEnabled { get; set; } = true;


        // this method is called form gdScript and can't handle 'Task'
        // we used explicit 'async void' to avoid  'Attempted to convert an unmarshallable managed type to Variant Task'
        public async void Execute(Godot.Node node)
        {
            try
            {
                var resourcePath = node.GetMeta("ResourcePath") as string;
                if (resourcePath == null)
                {
                    Godot.GD.PushWarning("Skip TestSuite, no 'ResourcePath' is defined.");
                    return;
                }
                var includedTests = node.GetChildren().Cast<Godot.Node>().ToList().Select(node => node.Name).ToList();
                await ExecuteInternally(new TestSuite(resourcePath, includedTests));
            }
            catch (Exception e)
            {
                Godot.GD.PushError(e.Message);
            }
            finally
            {
                node.Free();
            }
        }

        public async Task ExecuteInternally(TestSuite testSuite)
        {
            if (!ReportOrphanNodesEnabled)
                Godot.GD.PushWarning("!!! Reporting orphan nodes is disabled. Please check GdUnit settings.");
            try
            {

                using (ExecutionContext context = new ExecutionContext(testSuite, _eventListeners, ReportOrphanNodesEnabled))
                {
                    var task = new TestSuiteExecutionStage(testSuite).Execute(context);
                    task.GetAwaiter().OnCompleted(() => EmitSignal("ExecutionCompleted"));
                    await task;
                }
            }
            catch (Exception e)
            {
                // unexpected exceptions
                Godot.GD.PushError(e.Message);
                Godot.GD.PushError(e.StackTrace);
            }
            finally
            {
                testSuite.Dispose();
            }
        }
    }
}
