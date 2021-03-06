/**
 * Contains Prefabs and Prefab, manages creation and management of prefabs.
 */
module core.prefabs;
import core, components, utility;

import yaml;
import gl3n.linalg;
import std.variant;

/**
 * Prefabs manages prefabs and allows access to them.
 */
final abstract class Prefabs
{
public static:
	/// The AA of prefabs.
	Prefab[string] prefabs;

	/// Allows functions to be called on this like it were the AA.
	alias prefabs this;

	/**
	 * Load and initialize all prefabs in FilePath.Resources.Prefabs.
	 */
	void initialize()
	{
		foreach( key; prefabs.keys )
			prefabs.remove( key );

		void addObject( Node object )
		{
			auto name = object[ "Name" ].as!string;

			prefabs[ name ] = new Prefab( object );
		}

		foreach( file; FilePath.scanDirectory( FilePath.Resources.Prefabs, "*.yml" ) )
		{
			auto object = Config.loadYaml( file.fullPath );

			if( object.isSequence() )
				foreach( Node innerObj; object )
					addObject( innerObj );
			else
				addObject( object );
		}
	}
}

/**
 * A prefab that allows for quick object creation.
 */
final class Prefab : GameObject
{
public:
	/**
	 * Create a prefab from a YAML node.
	 * 
	 * Params:
	 * 	yml =			The YAML node to get info from.
	 */
	this( Node yml )
	{
		this.yaml = yml;
	}

	/**
	 * Creates a GameObject instance from the prefab.
	 * 
	 * Params:
	 * 	scriptOverride =			Create the instance from this class type instead of the prefab's default.
	 *
	 * Returns:
	 * 	The new GameObject from the Prefab.
	 */
	final GameObject createInstance( const ClassInfo scriptOverride = null )
	{
		return GameObject.createFromYaml( yaml, scriptOverride );
	}

private:
	Node yaml;
}
