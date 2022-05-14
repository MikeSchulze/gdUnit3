using System.Threading.Tasks;

namespace GdUnit3.Tests
{
    using Godot;
    using static Assertions;

    [TestSuite]
    class SceneRunnerTest
    {

        [Before]
        public void Setup()
        {
            // use a dedicated FPS because we calculate frames by time
            Engine.TargetFps = 60;
        }

        [After]
        public void TearDown()
        {
            Engine.TargetFps = 0;
        }

        [TestCase]
        public void GetProperty()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);
            AssertObject(runner.GetProperty<Godot.ColorRect>("_box1")).IsInstanceOf<Godot.ColorRect>();
            AssertThrown(() => runner.GetProperty<Godot.ColorRect>("_invalid"))
                .IsInstanceOf<System.MissingFieldException>()
                .HasMessage("The property '_invalid' not exist on loaded scene.");
        }

        [TestCase]
        public void InvokeSceneMethod()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);
            AssertString(runner.Invoke("add", 10, 12).ToString()).IsEqual("22");
            AssertThrown(() => runner.Invoke("sub", 12, 10))
                .IsInstanceOf<System.MissingMethodException>()
                .HasMessage("The method 'sub' not exist on loaded scene.");
        }

        [TestCase(Timeout = 1200)]
        public async Task AwaitForMilliseconds()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);
            System.Diagnostics.Stopwatch stopwatch = new System.Diagnostics.Stopwatch();
            stopwatch.Start();
            await runner.AwaitMillis(1000);
            stopwatch.Stop();
            // verify we wait around 1000 ms (using 100ms offset because timing is not 100% accurate)
            AssertInt((int)stopwatch.ElapsedMilliseconds).IsBetween(900, 1100);
        }

        [TestCase(Timeout = 2000)]
        public async Task SimulateFrames()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);

            var box1 = runner.GetProperty<Godot.ColorRect>("_box1");
            // initial is white
            AssertObject(box1.Color).IsEqual(Colors.White);

            // start color cycle by invoke the function 'start_color_cycle'
            runner.Invoke("start_color_cycle");

            // we wait for 10 frames
            await runner.SimulateFrames(10);
            // after 10 frame is still white
            AssertObject(box1.Color).IsEqual(Colors.White);

            // we wait 90 more frames
            await runner.SimulateFrames(90);
            // after 100 frames the box one should be changed the color
            AssertObject(box1.Color).IsNotEqual(Colors.White);
        }

        [TestCase(Timeout = 1000)]
        public async Task SimulateFramesWithDelay()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);

            var box1 = runner.GetProperty<Godot.ColorRect>("_box1");
            // initial is white
            AssertObject(box1.Color).IsEqual(Colors.White);

            // start color cycle by invoke the function 'start_color_cycle'
            runner.Invoke("start_color_cycle");

            // we wait for 10 frames each with a 50ms delay
            await runner.SimulateFrames(10, 50);
            // after 10 frame and in sum 500ms is should be changed to red
            AssertObject(box1.Color).IsEqual(Colors.Red);
        }

        [TestCase(Description = "Example to test a scene with do a color cycle on box one each 500ms", Timeout = 4000)]
        public async Task RunScene_ColorCycle()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);
            runner.MoveWindowToForeground();

            var box1 = runner.GetProperty<Godot.ColorRect>("_box1");
            // verify inital color
            AssertObject(box1.Color).IsEqual(Colors.White);

            // start color cycle by invoke the function 'start_color_cycle'
            runner.Invoke("start_color_cycle");

            // await for each color cycle is emited
            await runner.AwaitSignal("panel_color_change", box1, Colors.Red);
            AssertObject(box1.Color).IsEqual(Colors.Red);
            await runner.AwaitSignal("panel_color_change", box1, Colors.Blue);
            AssertObject(box1.Color).IsEqual(Colors.Blue);
            await runner.AwaitSignal("panel_color_change", box1, Colors.Green);
            AssertObject(box1.Color).IsEqual(Colors.Green);

            // AwaitOnSignal must fail after an maximum timeout of 500ms because no signal 'panel_color_change' with given args color=Yellow is emited
            await AssertThrown(runner.AwaitSignal("panel_color_change", box1, Colors.Yellow).WithTimeout(700))
                .ContinueWith(result => result.Result.IsInstanceOf<GdUnit3.Executions.ExecutionTimeoutException>().HasMessage("Timed out after 700ms."));
            // verify the box is still green
            AssertObject(box1.Color).IsEqual(Colors.Green);
        }

        [TestCase(Description = "Example to simulate the enter key is pressed to shoot a spell", Timeout = 2000)]
        public async Task RunScene_SimulateKeyPressed()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);

            // inital no spell is fired
            AssertObject(runner.FindNode("Spell")).IsNull();

            // fire spell be pressing enter key
            runner.SimulateKeyPressed(KeyList.Enter);
            // wait until next frame
            await runner.AwaitIdleFrame();

            // verify a spell is created
            AssertObject(runner.FindNode("Spell")).IsNotNull();

            // wait until spell is explode after around 1s
            var spell = runner.FindNode("Spell");
            // test to wait on signal with invlaid argument and must be timed out after 300ms
            await AssertThrown(spell.AwaitSignal("spell_explode", null).WithTimeout(300))
                .ContinueWith(result => result.Result.IsInstanceOf<GdUnit3.Executions.ExecutionTimeoutException>().HasMessage("Timed out after 300ms."));
            // now wait on signal with correct argument
            await spell.AwaitSignal("spell_explode", spell).WithTimeout(1100);

            // verify spell is removed when is explode
            AssertObject(runner.FindNode("Spell")).IsNull();
        }

        [TestCase(Description = "Example to simulate mouse pressed on buttons", Timeout = 2000)]
        public async Task RunScene_SimulateMouseEvents()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);
            runner.MoveWindowToForeground();

            var box1 = runner.GetProperty<Godot.ColorRect>("_box1");
            var box2 = runner.GetProperty<Godot.ColorRect>("_box2");
            var box3 = runner.GetProperty<Godot.ColorRect>("_box3");

            // verify inital colors
            AssertObject(box1.Color).IsEqual(Colors.White);
            AssertObject(box2.Color).IsEqual(Colors.White);
            AssertObject(box3.Color).IsEqual(Colors.White);

            // set mouse position to button one and simulate is pressed
            runner.SetMousePos(new Vector2(60, 20))
                .SimulateMouseButtonPressed(ButtonList.Left);

            // wait until next frame
            await runner.AwaitIdleFrame();
            // verify box one is changed to gray
            AssertObject(box1.Color).IsEqual(Colors.Gray);
            AssertObject(box2.Color).IsEqual(Colors.White);
            AssertObject(box3.Color).IsEqual(Colors.White);

            // set mouse position to button two and simulate is pressed
            runner.SetMousePos(new Vector2(160, 20))
                .SimulateMouseButtonPressed(ButtonList.Left);
            // verify box two is changed to gray
            AssertObject(box1.Color).IsEqual(Colors.Gray);
            AssertObject(box2.Color).IsEqual(Colors.Gray);
            AssertObject(box3.Color).IsEqual(Colors.White);

            // set mouse position to button three and simulate is pressed
            runner.SetMousePos(new Vector2(260, 20))
                .SimulateMouseButtonPressed(ButtonList.Left);
            // verify box three is changed to red and after around 1s to gray
            AssertObject(box3.Color).IsEqual(Colors.Red);
            await runner.AwaitSignal("panel_color_change", box3, Colors.Gray).WithTimeout(1100);
            AssertObject(box3.Color).IsEqual(Colors.Gray);
        }

        [TestCase(Description = "Example to wait for a specific method result", Timeout = 3000)]
        public async Task AwaitMethod()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);

            // wait until 'color_cycle()' returns 'black'
            await runner.AwaitMethod<string>("color_cycle").IsEqual("black");
            // verify the box is changed to green (last color cycle step)
            var box1 = runner.GetProperty<Godot.ColorRect>("_box1");
            AssertObject(box1.Color).IsEqual(Colors.Green);

            // wait for returns 'red' but will never happen and expect is interrupted after 500ms
            await AssertThrown(runner.AwaitMethod<string>("color_cycle").IsEqual("red").WithTimeout(1000))
               .ContinueWith(result => result.Result.HasMessage("Assertion: timed out after 500ms."));
        }

        [TestCase(Description = "Example to wait for a specific method result and used timefactor of 10", Timeout = 1000)]
        public async Task AwaitMethod_withTimeFactor()
        {
            ISceneRunner runner = ISceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn", true);

            runner.SetTimeFactor(10);
            // wait until 'color_cycle()' returns 'black' (using small timeout we expect the method will now processes 10 times faster)
            await runner.AwaitMethod<string>("color_cycle").IsEqual("black").WithTimeout(300);
            // verify the box is changed to green (last color cycle step)
            var box1 = runner.GetProperty<Godot.ColorRect>("_box1");
            AssertObject(box1.Color).IsEqual(Colors.Green);

            // wait for returns 'red' but will never happen and expect is interrupted after 250ms
            await AssertThrown(runner.AwaitMethod<string>("color_cycle").IsEqual("red").WithTimeout(250))
               .ContinueWith(result => result.Result.HasMessage("Assertion: timed out after 250ms."));
        }
    }
}
