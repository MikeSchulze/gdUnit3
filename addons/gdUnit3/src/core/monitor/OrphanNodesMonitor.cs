using static Godot.Performance;

namespace GdUnit3
{
    public class OrphanNodesMonitor
    {

        private int _orphanNodesStart = 0;
        private int _orphanCount = 0;

        public void Start(bool reset = false)
        {
            if (reset)
            {
                Reset();
            }
            _orphanNodesStart = GetMonitoredOrphanCount();
        }

        public void Stop()
        {
            _orphanCount += GetMonitoredOrphanCount() - _orphanNodesStart;
        }

        private int GetMonitoredOrphanCount() => (int)GetMonitor(Monitor.ObjectOrphanNodeCount);

        public int OrphanCount() => _orphanCount;

        public void Reset() => _orphanCount = 0;
    }
}
