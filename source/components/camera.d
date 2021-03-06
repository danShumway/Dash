/**
 * Defines the Camera class, which controls the view matrix for the world.
 */
module components.camera;
import core, components, graphics;

import gl3n.linalg;

import std.conv;

/**
 * Camera manages the viewmatrix and audio listeners for the world.
 */
final class Camera : IComponent
{
public:
	override void update() { }
	override void shutdown() { }

	mixin( DirtyGetter!( _viewMatrix, "updateViewMatrix" ) );

private:
	mat4 _viewMatrix;

	final void updateViewMatrix()
	{
		//Assuming pitch & yaw are in radians
		float cosPitch = cos( owner.transform.rotation.pitch );
		float sinPitch = sin( owner.transform.rotation.pitch );
		float cosYaw = cos( owner.transform.rotation.yaw );
		float sinYaw = sin( owner.transform.rotation.yaw );

		vec3 xaxis = vec3( cosYaw, 0.0f, -sinYaw );
		vec3 yaxis = vec3( sinYaw * sinPitch, cosPitch, cosYaw * sinPitch );
		vec3 zaxis = vec3( sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw );

		_viewMatrix.clear( 0.0f );
		_viewMatrix[ 0 ] = xaxis.vector ~ -( xaxis * owner.transform.position );
		_viewMatrix[ 1 ] = yaxis.vector ~ -( yaxis * owner.transform.position );
		_viewMatrix[ 2 ] = zaxis.vector ~ -( zaxis * owner.transform.position );
		_viewMatrix[ 3 ] = [ 0, 0, 0, 1 ];

		_viewMatrixIsDirty = false;
	}
}
