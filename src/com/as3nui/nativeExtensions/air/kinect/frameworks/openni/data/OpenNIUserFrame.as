package com.as3nui.nativeExtensions.air.kinect.frameworks.openni.data
{
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.UserFrame;
	
	public class OpenNIUserFrame extends UserFrame
	{
		public function OpenNIUserFrame(frameNumber:uint, timestamp:uint, users:Vector.<User>)
		{
			super(frameNumber, timestamp, users);
		}
	}
}