using System.Threading;
using System.Collections.Generic;

namespace GdUnit3.Executions.Monitors
{
    public class MemoryPool
    {
        private List<Godot.Object> _registeredObjects = new List<Godot.Object>();

        public void SetActive(string name)
        {
            //Godot.GD.PrintS("MemoryPool.SetActive", name, GetHashCode());
            Thread.SetData(Thread.GetNamedDataSlot("MemoryPool"), this);
        }

        public static T RegisterForAutoFree<T>(T obj) where T : Godot.Object
        {
            MemoryPool pool = (MemoryPool)Thread.GetData(Thread.GetNamedDataSlot("MemoryPool"));
            pool._registeredObjects.Add(obj);
            //Godot.GD.PrintS("MemoryPool.RegisterForAutoFree", pool._name, pool.GetHashCode(), "register", obj);
            return obj;
        }

        public void ReleaseRegisteredObjects()
        {
            //Godot.GD.PrintS("MemoryPool.ReleaseRegisteredObjects", _name, GetHashCode());
            _registeredObjects.ForEach(FreeInstance);
            _registeredObjects.Clear();
        }

        private void FreeInstance(Godot.Object obj)
        {
            // needs to manually exculde JavaClass see https://github.com/godotengine/godot/issues/44932
            if (Godot.Object.IsInstanceValid(obj) && !(obj is Godot.JavaClass))
            {
                if (obj is Godot.Reference)
                {
                    //Godot.GD.PrintS("Freeing Reference", obj);
                    obj.Notification(Godot.Object.NotificationPredelete);
                }
                else
                {
                    //Godot.GD.PrintS("Freeing Object", obj);
                    obj.Free();
                }
            }
        }
    }
}
