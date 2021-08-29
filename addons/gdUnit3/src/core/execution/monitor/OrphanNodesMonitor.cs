using static Godot.Performance;

namespace GdUnit3.Executions.Monitors
{
    public class OrphanNodesMonitor
    {

        public OrphanNodesMonitor(bool reportOrphanNodesEnabled)
        {
            ReportOrphanNodesEnabled = reportOrphanNodesEnabled;
        }


        public void Start(bool reset = false)
        {
            if (ReportOrphanNodesEnabled)
            {
                if (reset)
                    Reset();
                OrphanNodesStart = GetMonitoredOrphanCount();
            }
        }

        public void Stop()
        {
            if (ReportOrphanNodesEnabled)
                OrphanCount += GetMonitoredOrphanCount() - OrphanNodesStart;
        }

        private int GetMonitoredOrphanCount() => (int)GetMonitor(Monitor.ObjectOrphanNodeCount);

        private bool ReportOrphanNodesEnabled { get; set; }

        public int OrphanCount { get; private set; } = 0;

        private int OrphanNodesStart { get; set; } = 0;

        public void Reset() => OrphanCount = 0;
    }
}
