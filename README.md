
<h1 align="center">GdUnit3 <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/MikeSchulze/gdunit3" width="12%"> </h1>
<h2 align="center">A Godot Integrated Unit Testing Framework </h2>

<p align="center">
  <img src="https://img.shields.io/badge/Godot-v3.2.3-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.2.4-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.3-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.3.1-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.3.2-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.3.3-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.3.4-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.4-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v4.x.x-%23478cbf?logo=godot-engine&logoColor=cyian&color=red">
</p>

<p align="center"><a href="https://github.com/MikeSchulze/gdUnit3"><img src="https://github.com/MikeSchulze/gdUnit3/blob/master/assets/gdUnit3-animated.gif" width="100%"/></p><br/>


<p align="center">
  <img alt="GitHub branch checks state" src="https://img.shields.io/github/checks-status/MikeSchulze/gdunit3/master"></br>
  <img src="https://github.com/MikeSchulze/gdUnit3/actions/workflows/selftest-3.2.x.yml/badge.svg?branch=master"></br>
  <img src="https://github.com/MikeSchulze/gdUnit3/actions/workflows/selftest-3.3.x.yml/badge.svg?branch=master"></br>
  <img src="https://github.com/MikeSchulze/gdUnit3/actions/workflows/selftest-3.4.x.yml/badge.svg?branch=master"></br>
  <img src="https://github.com/MikeSchulze/gdUnit3/actions/workflows/selftest-3.3.x-mono.yml/badge.svg?branch=master"></br>

</p>



## What is GdUnit3
GdUnit3 is a framework for testing GdScrips and Scenes within the Godot editor. GdUnit3 is very useful for test-driven development and will help you get your code bug-free.
 
## Features
* Fully integrated in the Godot editor
* Run test-suite(s) by using the context menu on FileSystem, ScriptEditor or GdUnitInspector
* Create test's directly from the ScriptEditor
* A spacious set of Asserts use to verify your code
* Argument matchers to verify the behavior of a function call by a specified argument type.
* Fluent syntax support
* Test Fuzzing support
* Mocking a class to simulate the implementation which you define the output of certain function
* Spy on a instance to verify that a function has been called with certain parameters.
* Mock or Spy on a Scene 
* Provides a scene runner to simulate interactions on a scene 
  * Simulate by Input events like mouse and/or keyboard
  * Simulate scene processing by a certain number of frames
  * Simulate scene proccessing by waiting for a specific signal
* Update Notifier to install latest version from GitHub
* Command Line Tool [[Command-Line-Tool]]

 
## Short Example
 ```
 # this assertion succeeds
assert_int(13).is_not_negative()

# this assertion fail because the value '-13' is negative
assert_int(-13).is_not_negative()
 ```
 
## To Install the GdUnit3 Plugin

You have to install the GdUnit3 plugin over the AssetLib in the Godot Editor.
![image](https://github.com/MikeSchulze/gdUnit3/wiki/images/Install-AssetLib.png)
1. Select the tab AssetLib in the middle on the top
2. Enter GdUnit3 in the search bar
3. Select GdUnit3 and press the install button
4. Finally you have to activate the plugin

![image](https://github.com/MikeSchulze/gdUnit3/wiki/images/Activate-StepA.png)
1. Choose Project->Project Settings, click the Plugins tab and activate GdUnit.

![image](https://github.com/MikeSchulze/gdUnit3/wiki/images/Activate-StepB.png)

1. After activation the GdUnit3 inspector is displayed in the top left
2. Done, GdUnit is ready to use


You are welcome to report bugs or create new feature requests.
I would also appreciate feedback.

<a href="https://discord.gg/rdq36JwuaJ"><img src="https://img.shields.io/discord/885149082119733269?style=style=flat-square&label=Join GdUnit3 on Discord&color=7289DA" alt="Join GdUnit3 Server"/></a>

[Documentation](https://github.com/MikeSchulze/gdUnit3/wiki)

<h1 align="center"></h1>
<p align="left">
  <img alt="GitHub issues" src="https://img.shields.io/github/issues/MikeSchulze/gdunit3">
  <img alt="GitHub closed issues" src="https://img.shields.io/github/issues-closed-raw/MikeSchulze/gdunit3"></br>
  <!-- <img src="https://img.shields.io/packagecontrol/dm/SwitchDictionary.svg">
  <img src="https://img.shields.io/packagecontrol/dt/SwitchDictionary.svg">
   -->
  <img alt="GitHub top language" src="https://img.shields.io/github/languages/top/MikeSchulze/gdunit3">
  <img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/MikeSchulze/gdunit3">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg">
</p>

