using static Godot.Performance;

namespace GdUnit3
{
    public class OrphanNodesMonitor
    {

        public OrphanNodesMonitor(bool reportOrphanNodesEnabled)
        {
            ReportOrphanNodesEnabled = reportOrphanNodesEnabled;
            OrphanCount = 0;
            OrphanNodesStart = 0;
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

        public int OrphanCount { get; private set; }

        private int OrphanNodesStart { get; set; }

        public void Reset() => OrphanCount = 0;
    }
}
