using System;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;

namespace GdUnit3
{
    public static class GdUnitAwaiter
    {
        public static async Task<T> WithTimeout<T>(this Task<T> task, int timeoutMillis)
        {
            var wrapperTask = Task.Run(async () => await task);
            using var token = new CancellationTokenSource();
            var completedTask = await Task.WhenAny(wrapperTask, Task.Delay(timeoutMillis, token.Token));
            if (completedTask == wrapperTask)
            {
                token.Cancel();
                return await task;
            }
            throw new TimeoutException($"AwaitOnSignal: timed out after {timeoutMillis}ms.");
        }

        public static async Task<object> AwaitOnSignal(this GdUnit3.SceneRunner runner, string signal, params object[] args)
        {
            object[] signalArgs = await runner.Scene().ToSignal(runner.Scene(), signal);
            if (signalArgs.SequenceEqual(args))
                return default;
            return await AwaitOnSignal(runner, signal, args);
        }

        public static async Task<object> AwaitOnSignal(this Godot.Node node, string signal, params object[] args)
        {
            object[] signalArgs = await node.ToSignal(node, signal);
            if (signalArgs.SequenceEqual(args))
                return default;
            return await AwaitOnSignal(node, signal, args);
        }
    }
}

namespace GdUnit3.Core
{
    using Godot;
    using Executions;
    using Tools;
    internal sealed class SceneRunner : GdUnit3.SceneRunner
    {
        private SceneTree SceneTree { get; set; }
        private Node CurrentScene { get; set; }
        private bool Verbose { get; set; }
        private Vector2 CurrentMousePos { get; set; }
        private double TimeFactor { get; set; }
        private int SavedIterationsPerSecond { get; set; }

        public SceneRunner(string resourcePath, bool verbose = false)
        {
            Verbose = verbose;
            ExecutionContext.RegisterDisposable(this);
            SceneTree = Godot.Engine.GetMainLoop() as SceneTree;
            CurrentScene = (Godot.ResourceLoader.Load(resourcePath) as PackedScene).Instance();
            SceneTree.Root.AddChild(CurrentScene);
            CurrentMousePos = default;
            SavedIterationsPerSecond = (int)ProjectSettings.GetSetting("physics/common/physics_fps");
            SetTimeFactor(1.0);
        }

        public GdUnit3.SceneRunner SetMousePos(Vector2 position)
        {
            CurrentScene.GetViewport().WarpMouse(position);
            CurrentMousePos = position; return this;
        }

        public GdUnit3.SceneRunner SimulateKeyPress(KeyList key_code, bool shift = false, bool control = false)
        {
            PrintCurrentFocus();
            var action = new InputEventKey();
            action.Pressed = true;
            action.Scancode = ((uint)key_code);
            action.Shift = shift;
            action.Control = control;

            Print("	process key event {0} ({1}) <- {2}:{3}", CurrentScene, SceneName(), action.AsText(), action.IsPressed() ? "pressing" : "released");
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.SceneRunner SimulateKeyPressed(KeyList key_code, bool shift = false, bool control = false)
        {
            SimulateKeyPress(key_code, shift, control);
            SimulateKeyRelease(key_code, shift, control);
            return this;
        }

        public GdUnit3.SceneRunner SimulateKeyRelease(KeyList key_code, bool shift = false, bool control = false)
        {
            PrintCurrentFocus();
            var action = new InputEventKey();
            action.Pressed = false;
            action.Scancode = ((uint)key_code);
            action.Shift = shift;
            action.Control = control;

            Print("	process key event {0} ({1}) <- {2}:{3}", CurrentScene, SceneName(), action.AsText(), action.IsPressed() ? "pressing" : "released");
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.SceneRunner SimulateMouseMove(Vector2 relative, Vector2 speed = default)
        {
            var action = new InputEventMouseMotion();
            action.Relative = relative;
            action.Speed = speed == default ? Vector2.One : speed;

            Print("	process mouse motion event {0} ({1}) <- {2}", CurrentScene, SceneName(), action.AsText());
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.SceneRunner SimulateMouseButtonPressed(ButtonList buttonIndex)
        {
            SimulateMouseButtonPress(buttonIndex);
            SimulateMouseButtonRelease(buttonIndex);
            return this;
        }

        public GdUnit3.SceneRunner SimulateMouseButtonPress(ButtonList buttonIndex)
        {
            PrintCurrentFocus();
            var action = new InputEventMouseButton();
            action.ButtonIndex = (int)buttonIndex;
            action.ButtonMask = (int)buttonIndex;
            action.Pressed = true;
            action.Position = CurrentMousePos;
            action.GlobalPosition = CurrentMousePos;

            Print("	process mouse button event {0} ({1}) <- {2}", CurrentScene, SceneName(), action.AsText());
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.SceneRunner SimulateMouseButtonRelease(ButtonList buttonIndex)
        {
            var action = new InputEventMouseButton();
            action.ButtonIndex = (int)buttonIndex;
            action.ButtonMask = 0;
            action.Pressed = false;
            action.Position = CurrentMousePos;
            action.GlobalPosition = CurrentMousePos;

            Print("	process mouse button event {0} ({1}) <- {2}", CurrentScene, SceneName(), action.AsText());
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.SceneRunner SetTimeFactor(double timeFactor = 1.0)
        {
            TimeFactor = Math.Min(9.0, timeFactor);

            Print("set time factor: {0}", TimeFactor);
            Print("set physics iterations_per_second: {0}", SavedIterationsPerSecond * TimeFactor);
            return this;
        }

        public async Task<GdUnit3.SceneRunner> SimulateFrames(uint frames, uint deltaPeerFrame)
        {
            DeactivateTimeFactor();
            for (int frame = 0; frame < frames; frame++)
                await AwaitOnMillis(deltaPeerFrame);
            return this;
        }

        public async Task<GdUnit3.SceneRunner> SimulateFrames(uint frames)
        {
            var timeShiftFrames = Math.Max(1, frames / TimeFactor);
            ActivateTimeFactor();
            for (int frame = 0; frame < frames; frame++)
                await AwaitOnIdleFrame();
            DeactivateTimeFactor();
            return this;
        }

        private void ActivateTimeFactor()
        {
            Engine.TimeScale = (float)TimeFactor;
            Engine.IterationsPerSecond = (int)(SavedIterationsPerSecond * TimeFactor);
        }

        private void DeactivateTimeFactor()
        {
            Engine.TimeScale = 1;
            Engine.IterationsPerSecond = SavedIterationsPerSecond;
        }

        private void Print(string message, params object[] args)
        {
            if (Verbose)
                Console.WriteLine(String.Format(message, args));
        }

        private void PrintCurrentFocus()
        {
            if (!Verbose)
                return;
            var focusedNode = (CurrentScene as Control)?.GetFocusOwner();

            if (focusedNode != null)
                Console.WriteLine("	focus on {0}", focusedNode);
            else
                Console.WriteLine("	no focus set");
        }

        private string SceneName()
        {
            var sceneScript = CurrentScene.GetScript();

            if (!(sceneScript is Script))
                return CurrentScene.Name;
            if (!CurrentScene.Name.BeginsWith("@"))
                return CurrentScene.Name;

            return (sceneScript as Script).ResourceName.BaseName();
        }

        public Node Scene() => CurrentScene;

        public SignalAwaiter AwaitOnIdleFrame() => SceneTree.ToSignal(SceneTree, "idle_frame");

        public async Task AwaitOnMillis(uint timeMillis)
        {
            using (var tokenSource = new CancellationTokenSource())
            {
                await Task.Delay(System.TimeSpan.FromMilliseconds(timeMillis), tokenSource.Token);
            }
        }

        public SignalAwaiter AwaitOnSignal(string signal) => SceneTree.ToSignal(CurrentScene, signal);

        public object Invoke(string name, params object[] args)
        {
            if (!CurrentScene.HasMethod(name))
                throw new MissingMethodException($"The method '{name}' not exist on loaded scene.");
            return CurrentScene.Call(name, args);
        }

        public T GetProperty<T>(string name)
        {
            foreach (var element in CurrentScene.GetPropertyList())
            {
                if (element.ToString().Contains($"name:{name}"))
                    return (T)CurrentScene.Get(name);
            }
            throw new MissingFieldException($"The property '{name}' not exist on loaded scene.");
        }

        public Node FindNode(string name, bool recursive = true) => CurrentScene.FindNode(name, recursive, false);

        public void MoveWindowToForeground()
        {
            OS.WindowMaximized = true;
            OS.CenterWindow();
            OS.MoveWindowToForeground();
        }

        public void Dispose()
        {
            SceneTree.Root.RemoveChild(CurrentScene);
            CurrentScene.QueueFree();
        }
    }
}
