using System.Threading.Tasks;

namespace GdUnit3.Tests
{
    using Godot;
    using static Assertions;

    [TestSuite]
    class SceneRunnerTest
    {
        [TestCase]
        public void GetProperty()
        {
            SceneRunner scene = SceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn");
            AssertObject(scene.GetProperty<Godot.ColorRect>("_box1")).IsInstanceOf<Godot.ColorRect>();
            AssertThrown(() => scene.GetProperty<Godot.ColorRect>("_invalid"))
                .IsInstanceOf<System.MissingFieldException>()
                .HasMessage("The property '_invalid' not exist on loaded scene.");
        }

        [TestCase]
        public void InvokeSceneMethod()
        {
            SceneRunner scene = SceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn");
            AssertString(scene.Invoke("add", 10, 12).ToString()).IsEqual("22");
            AssertThrown(() => scene.Invoke("sub", 12, 10))
                .IsInstanceOf<System.MissingMethodException>()
                .HasMessage("The method 'sub' not exist on loaded scene.");
        }

        [TestCase(Description = "Example to test a scene with do a color cycle on box one each 500ms", Timeout = 4000)]
        public async Task RunScene_ColorCycle()
        {
            SceneRunner scene = SceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn");
            scene.MoveWindowToForeground();

            var box1 = scene.GetProperty<Godot.ColorRect>("_box1");
            // verify inital color
            AssertObject(box1.Color).IsEqual(Colors.White);

            // start color cycle by invoke the function 'start_color_cycle' 
            scene.Invoke("start_color_cycle");

            // await for each color cycle is emited
            await scene.AwaitOnSignal("panel_color_change", box1, Colors.Red);
            AssertObject(box1.Color).IsEqual(Colors.Red);
            await scene.AwaitOnSignal("panel_color_change", box1, Colors.Blue);
            AssertObject(box1.Color).IsEqual(Colors.Blue);
            await scene.AwaitOnSignal("panel_color_change", box1, Colors.Green);
            AssertObject(box1.Color).IsEqual(Colors.Green);

            // AwaitOnSignal must fail after an maximum timeout of 500ms because no signal 'panel_color_change' with given args color=Yellow is emited
            await AssertThrown(scene.AwaitOnSignal("panel_color_change", box1, Colors.Yellow).WithTimeout(700))
                .ContinueWith(result => result.Result.IsInstanceOf<System.TimeoutException>().HasMessage("AwaitOnSignal: timed out after 700ms."));
            // verify the box is still green
            AssertObject(box1.Color).IsEqual(Colors.Green);
        }

        [TestCase(Description = "Example to simulate the enter key is pressed to shoot a spell", Timeout = 2000)]
        public async Task RunScene_SimulateKeyPressed()
        {
            SceneRunner scene = SceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn");

            // inital no spell is fired
            AssertObject(scene.FindNode("Spell")).IsNull();

            // fire spell be pressing enter key
            scene.SimulateKeyPressed(KeyList.Enter);
            // wait until next frame
            await scene.OnIdleFrame();

            // verify a spell is created
            AssertObject(scene.FindNode("Spell")).IsNotNull();

            // wait until spell is explode after around 1s
            var spell = scene.FindNode("Spell");
            await spell.AwaitOnSignal("spell_explode", spell).WithTimeout(1100);

            // verify spell is removed when is explode
            AssertObject(scene.FindNode("Spell")).IsNull();
        }

        [TestCase(Description = "Example to simulate mouse pressed on buttons", Timeout = 2000)]
        public async Task RunScene_SimulateMouseEvents()
        {
            SceneRunner scene = SceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn");
            scene.MoveWindowToForeground();

            var box1 = scene.GetProperty<Godot.ColorRect>("_box1");
            var box2 = scene.GetProperty<Godot.ColorRect>("_box2");
            var box3 = scene.GetProperty<Godot.ColorRect>("_box3");

            // verify inital colors
            AssertObject(box1.Color).IsEqual(Colors.White);
            AssertObject(box2.Color).IsEqual(Colors.White);
            AssertObject(box3.Color).IsEqual(Colors.White);

            // set mouse position to button one and simulate is pressed
            scene.SetMousePos(new Vector2(60, 20))
                .SimulateMouseButtonPressed(ButtonList.Left);

            // wait until next frame
            await scene.OnIdleFrame();
            // verify box one is changed to gray
            AssertObject(box1.Color).IsEqual(Colors.Gray);
            AssertObject(box2.Color).IsEqual(Colors.White);
            AssertObject(box3.Color).IsEqual(Colors.White);

            // set mouse position to button two and simulate is pressed
            scene.SetMousePos(new Vector2(160, 20))
                .SimulateMouseButtonPressed(ButtonList.Left);
            // verify box two is changed to gray
            AssertObject(box1.Color).IsEqual(Colors.Gray);
            AssertObject(box2.Color).IsEqual(Colors.Gray);
            AssertObject(box3.Color).IsEqual(Colors.White);

            // set mouse position to button three and simulate is pressed
            scene.SetMousePos(new Vector2(260, 20))
                .SimulateMouseButtonPressed(ButtonList.Left);
            // verify box three is changed to red and after around 1s to gray
            AssertObject(box3.Color).IsEqual(Colors.Red);
            await scene.AwaitOnSignal("panel_color_change", box3, Colors.Gray).WithTimeout(1100);
            AssertObject(box3.Color).IsEqual(Colors.Gray);
        }
    }

}
