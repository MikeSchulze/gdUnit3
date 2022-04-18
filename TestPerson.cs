using Godot;

public class TestPerson : Node
{

	public TestPerson(string firstName, string lastName)
	{
		FirstName = firstName;
		LastName = lastName;
	}

	public string FirstName { get; }
	
	public string LastName { get; }
	
	public string FullName => Filename + " " + LastName;
}
