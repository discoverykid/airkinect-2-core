/*
 * Copyright 2012 AS3NUI
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
package com.as3nui.nativeExtensions.air.kinect {
	import com.as3nui.nativeExtensions.air.kinect.constants.DeviceState;
	import com.as3nui.nativeExtensions.air.kinect.constants.Framework;
	import com.as3nui.nativeExtensions.air.kinect.constants.OS;
	import com.as3nui.nativeExtensions.air.kinect.data.DeviceCapabilities;
	import com.as3nui.nativeExtensions.air.kinect.data.PointCloudRegion;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.UserFrame;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceErrorEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceInfoEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.PointCloudEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.UserEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.UserFrameEvent;
	import com.as3nui.nativeExtensions.air.kinect.frameworks.mssdk.MSKinect;
	import com.as3nui.nativeExtensions.air.kinect.frameworks.openni.OpenNIKinect;
	import com.as3nui.nativeExtensions.air.kinect.namespaces.as3nui;
	
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	use namespace as3nui;

	/**
	 * Dispatched when the device has started. Depending on your drivers (MSSDK / OpenNI) this can take a while.
	 */ 
	[Event(name="started", type="com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent")]
	
	/**
	 * Dispatched when the device stops. This can happen when you unplug the device from the computer.
	 */ 
	[Event(name="stopped", type="com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent")]
	
	/**
	 * Dispatched when the depth bitmapdata is updated.
	 */ 
	[Event(name="depthImageUpdate", type="com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent")]
	
	/**
	 * Dispatched when the rgb bitmapdata is updated.
	 */ 
	[Event(name="rgbImageUpdate", type="com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent")]
	
	/**
	 * Dispatched when new user(s) enter the scene.
	 */ 
	[Event(name="usersAdded", type="com.as3nui.nativeExtensions.air.kinect.events.UserEvent")]
	
	/**
	 * Dispatched when user(s) leave the scene.
	 */ 
	[Event(name="usersRemoved", type="com.as3nui.nativeExtensions.air.kinect.events.UserEvent")]
	
	/**
	 * Dispatched when new user skeleton(s) are detected.
	 */ 
	[Event(name="usersWithSkeletonAdded", type="com.as3nui.nativeExtensions.air.kinect.events.UserEvent")]
	
	/**
	 * Dispatched when user(s) with a skeleton leave the scene.
	 */ 
	[Event(name="usersWithSkeletonRemoved", type="com.as3nui.nativeExtensions.air.kinect.events.UserEvent")]
	
	/**
	 * Dispatched when user(s) coordinates are updated.
	 */ 
	[Event(name="usersUpdated", type="com.as3nui.nativeExtensions.air.kinect.events.UserEvent")]
	
	/**
	 * Dispatched when user mask bitmap(s) are updated.
	 */ 
	[Event(name="usersMaskImageUpdate", type="com.as3nui.nativeExtensions.air.kinect.events.UserEvent")]
	
	/**
	 * Dispatched when new point cloud information is available.
	 */ 
	[Event(name="pointCloudUpdate", type="com.as3nui.nativeExtensions.air.kinect.events.PointCloudEvent")]

	/**
	 * The Kinect class allows you to access skeleton tracking device hardware in your AIR applications.
	 *
	 * <p>An instance of this class will give you access to the different video streams
	 * and skeleton information of a Kinect sensor.</p>
	 *
	 * @includeExample BasicSkeletonExample.as
	 * @includeExample BasicCameraExample.as
	 */
	public class Kinect extends EventDispatcher {
		
		/** @private */
		protected static const EXTENSION_EVENT_DEVICE_STARTED:String = 'started';
		/** @private */
		protected static const EXTENSION_EVENT_DEVICE_STOPPED:String = 'stopped';

		/** @private */
		protected static const EXTENSION_EVENT_RGB_FRAME_AVAILABLE:String = 'RGBFrame';
		/** @private */
		protected static const EXTENSION_EVENT_DEPTH_FRAME_AVAILABLE:String = 'depthFrame';
		/** @private */
		protected static const EXTENSION_EVENT_USER_FRAME_AVAILABLE:String = 'userFrame';
		/** @private */
		protected static const EXTENSION_EVENT_USERMASK_FRAME_AVAILABLE:String = 'userMaskFrame';
		/** @private */
		protected static const EXTENSION_EVENT_POINTCLOUD_FRAME_AVAILABLE:String = 'pointCloudFrame';

		//SHARED CONTEXT REQUESTS
		/** @private */
		protected static const EXTENSION_REQUEST_APPLICATION_STARTUP:String = "applicationStartup";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_DEVICE_COUNT:String = "getDeviceCount";
		/** @private */
		protected static const EXTENSION_REQUEST_APPLICATION_SHUTDOWN:String = "applicationShutdown";

		//Main Context Requests
		/** @private */
		protected static const EXTENSION_REQUEST_START:String = "start";
		/** @private */
		protected static const EXTENSION_REQUEST_STOP:String = "stop";
		
		/** @private */
		protected static const EXTENSION_REQUEST_GET_CAPABILITIES:String = "getCapabilities";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_USER_MODE:String = "setUserMode";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_USER_COLOR:String = "setUserColor";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_USER_ENABLED:String = "setUserEnabled";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_SKELETON_MODE:String = "setSkeletonMode";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_SKELETON_ENABLED:String = "setSkeletonEnabled";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_USER_FRAME:String = "getUserFrame";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_SKELETON_JOINT_NAME_INDICIES:String = "getSkeletonJointNameIndices";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_SKELETON_JOINT_NAMES:String = "getSkeletonJointNames";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_USER_MASK_MODE:String = "setUserMaskMode";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_USER_MASK_ENABLED:String = "setUserMaskEnabled";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_USER_MASK_FRAME:String = "getUserMaskFrame";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_DEPTH_MODE:String = "setDepthMode";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_DEPTH_ENABLED:String = "setDepthEnabled";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_DEPTH_FRAME:String = "getDepthFrame";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_DEPTH_SHOW_USER_COLORS:String = "setDepthShowUserColors";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_DEPTH_ENABLE_NEAR_MODE:String = "setDepthEnableNearMode";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_RGB_MODE:String = "setRGBMode";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_RGB_ENABLED:String = "setRGBEnabled";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_RGB_FRAME:String = "getRGBFrame";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_POINTCLOUD_MODE:String = "setPointCloudMode";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_POINTCLOUD_ENABLED:String = "setPointCloudEnabled";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_POINTCLOUD_FRAME:String = "getPointCloudFrame";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_POINTCLOUD_REGIONS:String = "setPointCloudRegions";
		/** @private */
		protected static const EXTENSION_REQUEST_GET_CAMERA_ELEVATION_ANGLE:String = "getCameraElevationAngle";
		/** @private */
		protected static const EXTENSION_REQUEST_SET_CAMERA_ELEVATION_ANGLE:String = "setCameraElevationAngle";

		/** @private */
		protected static const EXTENSION_EVENT_DISCONNECT:String = 'deviceDisconnected';
		/** @private */
		protected static const EXTENSION_EVENT_RECONNECT:String = 'deviceReconnected';
		/** @private */
		protected static const EXTENSION_EVENT_ERROR:String = 'error';

		/** @private */
		protected static const USE_GET_INSTANCE:String = 'Classes extending Device can only be instantiated once by the getInstance method';
		/** @private */
		protected static const CLASS_MUST_EXTEND_DEVICE:String = 'Device is a base class that cannot be instantiated';
		/** @private */
		protected static const GET_INSTANCE_OF_CLASS_ERROR:String = 'getInstance can only be called for Classes extending Device';

		/**
		 * internal dictionary to keep class instances
		 * @private
		 */
		private static var _deviceInstanceMap:Dictionary;
		private static var _sharedContext:ExtensionContext;


		private static function get sharedContext():ExtensionContext {
			if (_sharedContext == null) {
				_sharedContext = ExtensionContext.createExtensionContext("com.as3nui.nativeExtensions.air.kinect", "shared");
			}
			return _sharedContext;
		}


		/**
		 * Check if there is a Sensor available for use
		 */
		public static function isSupported():Boolean {
			return (numDevices() > 0);
		}

		/**
		 * Get the current number of sensors connected to the system
		 * @return    Number of Sensors connected
		 */
		public static function numDevices():uint {
			return (sharedContext.call(EXTENSION_REQUEST_GET_DEVICE_COUNT) as uint);
		}

		/**
		 * Get an instance of the Kinect class. You'll use this method to get
		 * instances of the class, instead of creating instances yourself.
		 * @param deviceClass
		 * @param nr
		 * @return
		 */
		public static function getDeviceByClass(deviceClass:Class, nr:uint = 0):Kinect {
			if (_deviceInstanceMap == null) _deviceInstanceMap = new Dictionary();
			if (_deviceInstanceMap[deviceClass] == null)  _deviceInstanceMap[deviceClass] = new Dictionary();
			if (_deviceInstanceMap[deviceClass][nr] == null) {
				_deviceInstanceMap[deviceClass][nr] = new deviceClass(nr);
			}
			return _deviceInstanceMap[deviceClass][nr];
		}

		/**
		 * Get an instance of the Kinect class. You'll use this method to get
		 * instances of the class, instead of creating instances yourself.
		 * @param framework        @see com.as3nui.nativeExtensions.air.kinect.constants.Framework
		 * @param nr        DeviceId to get
		 * @return
		 */
		public static function getDeviceByFramework(framework:String, nr:uint = 0):Kinect {
			var deviceClass:Class = Framework.MSSDK ? MSKinect : OpenNIKinect;
			return getDeviceByClass(deviceClass, nr);
		}

		/**
		 * Automatically chooses from the "default" devices for an operating system
		 * this is currently OpenNI for OSX and MSSDK for windows
		 * @param nr    Device number to get
		 * @return
		 */
		public static function getDevice(nr:uint = 0):Kinect {
			var deviceClass:Class = OS.isWindows() ? MSKinect : OpenNIKinect;
			return getDeviceByClass(deviceClass, nr);
		}

		/** @private */
		protected var _nr:uint;

		/**
		 * Get the index / nr of the Device.
		 */
		public function get nr():uint {
			return _nr;
		}
		
		private var _capabilities:DeviceCapabilities;
		
		/**
		 * Get the capabilities of the Device.
		 */ 
		public function get capabilities():DeviceCapabilities {
			if (!_capabilities) {
				var nativeCapabilities:Object = context.call(EXTENSION_REQUEST_GET_CAPABILITIES, _nr) as Object;
				_capabilities = new DeviceCapabilities(nativeCapabilities);
			}
			return _capabilities;
		}

		/** @private */
		protected var _state:String;

		/**
		 * Get the current state of the Device.
		 *
		 * <p>Possible options are <code>DeviceState.STARTED, DeviceState.STOPPED, DeviceState.STARTING</code>.</p>
		 *
		 * @see com.as3nui.nativeExtensions.air.kinect.constants.DeviceState
		 */
		public function get state():String {
			return _state;
		}
		
		/**
		 * Gets the current angle of the Device.
		 * 
		 * Not all devices / drivers support this option.
		 * Check capabilities.hasCameraElevationSupport
		 */ 
		public function get cameraElevationAngle():int {
			return context.call(EXTENSION_REQUEST_GET_CAMERA_ELEVATION_ANGLE, _nr) as int;
		}
		
		/**
		 * Sets the current angle of the Device
		 * 
		 * Not all devices / drivers support this option.
		 * Check capabilities.hasCameraElevationSupport
		 */ 
		public function set cameraElevationAngle(value:int):void {
			context.call(EXTENSION_REQUEST_SET_CAMERA_ELEVATION_ANGLE, _nr, value);
		}

		/** @private */
		protected var context:ExtensionContext;
		/** @private */
		protected var _settings:KinectSettings;
		/** @private */
		protected var _userSimulationMode:Boolean;


		// Depth Image Variables
		/** @private */
		protected var depthImageBytes:ByteArray;
		/** @private */
		protected var depthImageData:BitmapData;

		// RGB Variables
		/** @private */
		protected var rgbImageBytes:ByteArray;
		/** @private */
		protected var rgbImageData:BitmapData;

		// PointCloud Variables
		/** @private */
		protected var pointCloudBytes:ByteArray;
		/** @private */
		protected var pointCloudRegions:Vector.<PointCloudRegion>;

		// User/Skeleton Variables
		/** @private */
		protected var _users:Vector.<User>;
		/** @private */
		protected var usersByTrackingId:Dictionary;
		/** @private */
		protected var _usersWithSkeleton:Vector.<User>;
		/** @private */
		protected var usersWithSkeletonByTrackingId:Dictionary;
		/** @private */
		protected var _skeletonJointNameIndices:Dictionary;
		/** @private */
		protected var _skeletonJointNames:Vector.<String>;
		/** @private */
		protected var userMaskByteArrays:Vector.<ByteArray>;
		
		//static intialization of the shared context
		//parameter lets you specify which framework to use on windows
		//0: auto, 1: mssdk, 2: openni
		//will be used as soon as we figure out how to prevent ane from crashing when driver requirements are not met
		private static var applicationStarted:* = sharedContext.call(EXTENSION_REQUEST_APPLICATION_STARTUP, 0);

		/**
		 * Private constructor of the Device class. Use Device.getDevice() instead of calling this method.
		 * @private
		 */
		public function Kinect(nr:uint) {
			var className:String = getQualifiedClassName(this);
			var managementClass:Class = getDefinitionByName(className) as Class;

			if (managementClass == Kinect) {
				throw(CLASS_MUST_EXTEND_DEVICE);
			}

			var instance:Kinect = _deviceInstanceMap[managementClass][nr];
			if (instance != null) {
				throw(USE_GET_INSTANCE);
			}
			else {
				_deviceInstanceMap[managementClass][nr] = this;
			}

			_nr = nr;
			_state = DeviceState.STOPPED;
			
			//create the extension _context
			context = ExtensionContext.createExtensionContext("com.as3nui.nativeExtensions.air.kinect", null);

			//dispose the kinect on application exit
			NativeApplication.nativeApplication.addEventListener("exiting", exitingHandler, false, 0, true);
		}

		/**
		 * Starts the kinect sensor, with the given configuration.
		 *
		 * @see com.as3nui.nativeExtensions.air.kinect.KinectSettings
		 */
		public function start(deviceSettings:Object):void {
			if (_state == DeviceState.STOPPED) {
				_settings = parseSettings(deviceSettings);
				_state = DeviceState.STARTING;
				//add status listener to the _context
				context.addEventListener(StatusEvent.STATUS, contextStatusHandler, false, 0, true);
				//Initialize all variales needed for settings requested
				initSettings();
				//start the _context
				context.call(EXTENSION_REQUEST_START, _nr);
				//the started event will be dispatched from the _context, as this can take a while
			}
		}
		
		/** @private */
		protected function parseSettings(deviceSettings:Object):KinectSettings
		{
			throw new Error("You need to implement the parseSettings method inside your device implementation");
			return null;
		}

		/**
		 * Stops the Device.
		 */
		public function stop():void {
			if (_state == DeviceState.STARTED || _state == DeviceState.STARTING) {
				_state = DeviceState.STOPPED;
				//remove the status listener
				context.removeEventListener(StatusEvent.STATUS, contextStatusHandler);
				//stop the _context
				context.call(EXTENSION_REQUEST_STOP, _nr);
				disposeSettings();
				//dispatch the stopped event
				dispatchEvent(new DeviceEvent(DeviceEvent.STOPPED));
			}
		}

		/**
		 * Cleanup the Device instance.
		 */
		public function dispose():void {
			stop();
			var className:String = getQualifiedClassName(this);
			var managementClass:Class = getDefinitionByName(className) as Class;
			delete _deviceInstanceMap[managementClass][_nr];
		}

		private function exitingHandler(event:Event):void {
			dispose();
			sharedContext.call(EXTENSION_REQUEST_APPLICATION_SHUTDOWN);
		}

		/** @private */
		protected function initSettings():void {
			initRGBSettings();
			initDepthSettings();
			initPointCloudSettings();
			initUserSettings();
			initUserMaskSettings();
		}

		/** @private */
		protected function disposeSettings():void{
			disposeRGBSettings();
			disposeDepthSettings();
			disposePointCloudSettings();
			disposeUserSettings();
			disposeUserMaskSettings();
		}

		//----------------------------------
		//  RGB Camera Handers
		//----------------------------------
		/** @private */
		protected function initRGBSettings():void {
			if (_settings.rgbEnabled) {
				//RGB Image Variables
				rgbImageBytes = new ByteArray();
				rgbImageData = new BitmapData(_settings.rgbResolution.x, _settings.rgbResolution.y, true, 0x000000);
			}
			applyRGBSettings();
		}

		/** @private */
		protected function applyRGBSettings():void {
			context.call(EXTENSION_REQUEST_SET_RGB_ENABLED, _nr, _settings.rgbEnabled);
			context.call(EXTENSION_REQUEST_SET_RGB_MODE, _nr, _settings.rgbResolution.x, _settings.rgbResolution.y, _settings.rgbMirrored);
		}

		/** @private */
		private function disposeRGBSettings():void {
			rgbImageBytes = null;
			if(rgbImageData) rgbImageData.dispose();
		}

		//----------------------------------
		// Depth Camera Handlers
		//----------------------------------
		
		/** @private */
		protected function initDepthSettings():void {
			if (_settings.depthEnabled) {
				//Depth Image Variables
				depthImageBytes = new ByteArray();
				depthImageData = new BitmapData(_settings.depthResolution.x, _settings.depthResolution.y, true, 0x000000);
			}
			applyDepthImageSettings()
		}

		/** @private */
		protected function applyDepthImageSettings():void {
			context.call(EXTENSION_REQUEST_SET_DEPTH_ENABLED, _nr, _settings.depthEnabled);
			context.call(EXTENSION_REQUEST_SET_DEPTH_MODE, _nr, _settings.depthResolution.x, _settings.depthResolution.y, _settings.depthMirrored);
			context.call(EXTENSION_REQUEST_SET_DEPTH_SHOW_USER_COLORS, _nr, _settings.depthShowUserColors);
			context.call(EXTENSION_REQUEST_SET_DEPTH_ENABLE_NEAR_MODE, _nr, _settings.depthEnableNearMode);
		}

		/** @private */
		private function disposeDepthSettings():void {
			depthImageBytes = null;
			if(depthImageData) depthImageData.dispose();
		}

		//----------------------------------
		// Point Cloud Handlers
		//----------------------------------
		/** @private */
		protected function initPointCloudSettings():void {
			if (_settings.pointCloudEnabled) {
				//Point Cloud Variables
				pointCloudBytes = new ByteArray();
				pointCloudRegions = new <PointCloudRegion>[];
			}
			applyPointCloudSettings();
		}

		/** @private */
		protected function applyPointCloudSettings():void {
			context.call(EXTENSION_REQUEST_SET_POINTCLOUD_ENABLED, _nr, _settings.pointCloudEnabled);
			context.call(EXTENSION_REQUEST_SET_POINTCLOUD_MODE, _nr, _settings.pointCloudResolution.x, _settings.pointCloudResolution.y, _settings.pointCloudMirrored, _settings.pointCloudDensity, _settings.pointCloudIncludeRGB);
		}

		/** @private */
		private function disposePointCloudSettings():void {
			pointCloudBytes = null;
			pointCloudRegions = new <PointCloudRegion>[];
		}

		/** @private */
		public function setPointCloudRegions(pointCloudRegions:Vector.<PointCloudRegion>):void {
			this.pointCloudRegions = pointCloudRegions;
			if (context != null)  context.call(EXTENSION_REQUEST_SET_POINTCLOUD_REGIONS, _nr, pointCloudRegions);
		}

		//----------------------------------
		// User/Skeleton Handlers
		//----------------------------------
		/** @private */
		protected function initUserSettings():void {
			if (_settings.skeletonEnabled || _settings.userEnabled || _settings.userMaskEnabled) {
				_users = new Vector.<User>();
				usersByTrackingId = new Dictionary();
				_usersWithSkeleton = new Vector.<User>();
				usersWithSkeletonByTrackingId = new Dictionary();
				_skeletonJointNameIndices = context.call(EXTENSION_REQUEST_GET_SKELETON_JOINT_NAME_INDICIES, _nr) as Dictionary;
				_skeletonJointNames = context.call(EXTENSION_REQUEST_GET_SKELETON_JOINT_NAMES, _nr) as Vector.<String>;
			}
			applyUserSettings()
		}
		/** @private */
		protected function applyUserSettings():void {
			context.call(EXTENSION_REQUEST_SET_USER_ENABLED, _nr, _settings.userEnabled);
			context.call(EXTENSION_REQUEST_SET_USER_MODE, _nr, _settings.userMirrored);
			context.call(EXTENSION_REQUEST_SET_SKELETON_ENABLED, _nr, _settings.skeletonEnabled);
			context.call(EXTENSION_REQUEST_SET_SKELETON_MODE, _nr, _settings.skeletonMirrored);
		}
		/** @private */
		private function disposeUserSettings():void {
			if(_users) _users.length = 0;
			usersByTrackingId = new Dictionary();
			if(_usersWithSkeleton) _usersWithSkeleton.length = 0;
			usersWithSkeletonByTrackingId = new Dictionary();
		}

		//----------------------------------
		// User Mask Handlers
		//----------------------------------
		/** @private */
		protected function initUserMaskSettings():void {
			if (_settings.userMaskEnabled) {
				userMaskByteArrays = new Vector.<ByteArray>();
				for (var i:uint = 0; i < 15; i++) {
					userMaskByteArrays.push(new ByteArray());
				}
			}
			applyUserMaskSettings();
		}
		/** @private */
		protected function applyUserMaskSettings():void {
			context.call(EXTENSION_REQUEST_SET_USER_MASK_ENABLED, _nr, _settings.userMaskEnabled);
			context.call(EXTENSION_REQUEST_SET_USER_MASK_MODE, _nr, _settings.userMaskResolution.x, _settings.userMaskResolution.y, _settings.userMaskMirrored);
		}
		/** @private */
		private function disposeUserMaskSettings():void {
			userMaskByteArrays = null;
		}

		// -------------------------------------------
		// Real Time Adjustable _settings features
		// -------------------------------------------
		/**
		 * Change the skeleton mirroring while the device is running
		 */ 
		public function setSkeletonMirror(value:Boolean):void {
			_settings.skeletonMirrored = value;
			applyUserSettings();
		}

		/**
		 * Change the depth image mirroring while the device is running
		 */ 
		public function setDepthMirror(value:Boolean):void {
			_settings.depthMirrored = value;
			applyDepthImageSettings();
		}

		/**
		 * Change the rgb image mirroring while the device is running
		 */ 
		public function setRGBMirror(value:Boolean):void {
			_settings.rgbMirrored = value;
			applyRGBSettings()
		}

		/**
		 * Change the user mask mirroring while the device is running
		 */ 
		public function setUserMaskMirror(value:Boolean):void {
			_settings.userMaskMirrored = value;
			applyUserMaskSettings();
		}

		/**
		 * Change the point cloud mirroring while the device is running
		 */ 
		public function setPointCloudMirror(value:Boolean):void {
			_settings.pointCloudMirrored = value;
			applyPointCloudSettings();
		}

		/**
		 * Change the density of the point cloud while the device is running.
		 */ 
		public function setPointCloudDensity(value:uint):void {
			_settings.pointCloudDensity = value;
			applyPointCloudSettings();
		}

		/**
		 * Change the inclusion of RGB data in the point cloud while the device is running
		 */ 
		public function setPointCloudIncludeRGB(value:Boolean):void {
			_settings.pointCloudIncludeRGB = value;
			applyPointCloudSettings();
		}

		/** @private */
		protected function contextStatusHandler(event:StatusEvent):void {
//			trace("[Kinect] contextStatusHandler", event.code, event.level);
			switch (event.code) {
				case "status":
					switch (event.level) {
						case EXTENSION_EVENT_DEVICE_STARTED:
							handleDeviceStarted();
							break;
						case EXTENSION_EVENT_DEVICE_STOPPED:
							handleDeviceStopped();
							break;
						case EXTENSION_EVENT_DEPTH_FRAME_AVAILABLE:
							handleDepthFrame();
							break;
						case EXTENSION_EVENT_RGB_FRAME_AVAILABLE:
							handleRGBFrame();
							break;
						case EXTENSION_EVENT_POINTCLOUD_FRAME_AVAILABLE:
							handlePointCloudFrame();
							break;
						case EXTENSION_EVENT_USER_FRAME_AVAILABLE:
							handleUserFrame();
							break;
						case EXTENSION_EVENT_USERMASK_FRAME_AVAILABLE:
							handleUserMaskFrame();
							break;
						case EXTENSION_EVENT_RECONNECT:
							start(_settings);
							break;
					}
					break;
				case "trace":
					trace(event.level);
					break;
				case "info":
					this.dispatchEvent(new DeviceInfoEvent(event.level));
					break;
				case "error":
					this.dispatchEvent(new DeviceErrorEvent(event.level));
					break;
			}
		}

		// -------------------------------------------
		// Device Event Handling
		// -------------------------------------------
		/** @private */
		protected function handleDeviceStarted():void {
			_state = DeviceState.STARTED;
			if (hasEventListener(DeviceEvent.STARTED)) dispatchEvent(new DeviceEvent(DeviceEvent.STARTED));
		}

		/** @private */
		protected function handleDeviceStopped():void {
			if (hasEventListener(DeviceEvent.STOPPED)) dispatchEvent(new DeviceEvent(DeviceEvent.STOPPED));
		}

		// -------------------------------------------
		// Depth Frame Event Handling
		// -------------------------------------------
		/** @private */
		protected function handleDepthFrame():void {
			if (!hasEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE)) return;
			if(depthImageBytes == null || depthImageData == null) return;
			context.call(EXTENSION_REQUEST_GET_DEPTH_FRAME, _nr, depthImageBytes);
			depthImageBytes.position = 0;
			depthImageBytes.endian = Endian.LITTLE_ENDIAN;
			depthImageData.setPixels(depthImageData.rect, depthImageBytes);

			//dispatch the event
			dispatchEvent(new CameraImageEvent(CameraImageEvent.DEPTH_IMAGE_UPDATE, false, false, depthImageData));
		}

		// -------------------------------------------
		// RGB Frame Event Handling
		// -------------------------------------------
		/** @private */
		protected function handleRGBFrame():void {
			if (!hasEventListener(CameraImageEvent.RGB_IMAGE_UPDATE)) return;
			if(rgbImageBytes == null || rgbImageData == null) return;

			context.call(EXTENSION_REQUEST_GET_RGB_FRAME, _nr, rgbImageBytes);
			rgbImageBytes.position = 0;
			rgbImageBytes.endian = Endian.LITTLE_ENDIAN;
			rgbImageData.setPixels(rgbImageData.rect, rgbImageBytes);

			//dispatch the event
			dispatchEvent(new CameraImageEvent(CameraImageEvent.RGB_IMAGE_UPDATE, false, false, rgbImageData));
		}

		// -------------------------------------------
		// PointCloud Frame Event Handling
		// -------------------------------------------
		/** @private */
		protected function handlePointCloudFrame():void {
			if (!hasEventListener(PointCloudEvent.POINT_CLOUD_UPDATE)) return;
			if(pointCloudBytes == null) return;
			context.call(EXTENSION_REQUEST_GET_POINTCLOUD_FRAME, _nr, pointCloudBytes, pointCloudRegions);
			pointCloudBytes.position = 0;
			pointCloudBytes.endian = Endian.LITTLE_ENDIAN;
			dispatchEvent(new PointCloudEvent(PointCloudEvent.POINT_CLOUD_UPDATE, false, false, pointCloudBytes, pointCloudRegions));
		}

		// -------------------------------------------
		// UserMask Frame Event Handling
		// -------------------------------------------
		/** @private */
		protected function handleUserMaskFrame():void {
			//we should also enable user masks on enter frame, so
			//don't check for the specific event listener
			//if (!hasEventListener(UserEvent.USERS_MASK_IMAGE_UPDATE)) return;
			if(users == null) return;

			var i:uint = 0;
			for each(var user:User in users) {
				context.call(EXTENSION_REQUEST_GET_USER_MASK_FRAME, _nr, user.userID, userMaskByteArrays[i]);
				userMaskByteArrays[i].position = 0;
				userMaskByteArrays[i].endian = Endian.LITTLE_ENDIAN;
				if (user.userMaskData == null) {
					user.userMaskData = new BitmapData(_settings.userMaskResolution.x, _settings.userMaskResolution.y, true, 0);
				}
				user.userMaskData.setPixels(user.userMaskData.rect, userMaskByteArrays[i]);
				i++;
			}
			if (users.length > 0) {
				dispatchEvent(new UserEvent(UserEvent.USERS_MASK_IMAGE_UPDATE, false, false, users));
			}
		}

		// -------------------------------------------
		// User Frame Event Handling
		// -------------------------------------------
		/** @private */
		protected function handleUserFrame():void {
			if (userSimulationMode) return;
			var userFrame:UserFrame = context.call(EXTENSION_REQUEST_GET_USER_FRAME, _nr) as UserFrame;
			processUserFrame(userFrame);
		}

		/** @private */
		protected function processUserFrame(userFrame:UserFrame):void {
			//Allows for manual digesting of full user frame. This event should not be used
			this.dispatchEvent(new UserFrameEvent(userFrame));

			//update the users - copy the data inside existing users, so user references keep working
			var user:User;
			var otherUser:User;

			//which users should we remove?
			var removedUsers:Vector.<User> = getUsersToRemoveAndRemoveFromDictionary(userFrame.users, _users, usersByTrackingId);
			var removedUsersWithSkeleton:Vector.<User> = getUsersToRemoveAndRemoveFromDictionary(userFrame.usersWithSkeleton, _usersWithSkeleton, usersWithSkeletonByTrackingId);
			var addedUsers:Vector.<User> = new Vector.<User>();
			var addedUsersWithSkeleton:Vector.<User> = new Vector.<User>();
			var currentUsers:Vector.<User> = new Vector.<User>();
			var currentUsersWithSkeleton:Vector.<User> = new Vector.<User>();
			for each(otherUser in userFrame.users) {
				//existing? Update the properties
				user = usersByTrackingId[otherUser.trackingID];
				if (user != null) {
					user.copyFrom(otherUser);
				}
				else {
					usersByTrackingId[otherUser.trackingID] = user = otherUser;
					addedUsers.push(user);
				}

				user.as3nui::skeletonJointNameIndices = _skeletonJointNameIndices;
				user.as3nui::_skeletonJointNames = _skeletonJointNames;
				currentUsers.push(user);
				if (user.hasSkeleton) {
					currentUsersWithSkeleton.push(user);
					if (usersWithSkeletonByTrackingId[user.trackingID] == null) {
						usersWithSkeletonByTrackingId[otherUser.trackingID] = user;
						addedUsersWithSkeleton.push(user);
					}
				}
			}

			_users = currentUsers;
			_usersWithSkeleton = currentUsersWithSkeleton;

			//dispatch removed event
			if (removedUsers.length > 0) {
				dispatchEvent(new UserEvent(UserEvent.USERS_REMOVED, false, false, removedUsers));
			}
			if (removedUsersWithSkeleton.length > 0) {
				dispatchEvent(new UserEvent(UserEvent.USERS_WITH_SKELETON_REMOVED, false, false, removedUsersWithSkeleton));
			}
			//dispatch added event
			if (addedUsers.length > 0) {
				dispatchEvent(new UserEvent(UserEvent.USERS_ADDED, false, false, addedUsers));
			}
			if (addedUsersWithSkeleton.length > 0) {
				dispatchEvent(new UserEvent(UserEvent.USERS_WITH_SKELETON_ADDED, false, false, addedUsersWithSkeleton));
			}
			//dispatch updated event
			dispatchEvent(new UserEvent(UserEvent.USERS_UPDATED, false, false, _users));

		}

		/** @private */
		private function getUsersToRemoveAndRemoveFromDictionary(newUsers:Vector.<User>, previousUsers:Vector.<User>, dictionary:Dictionary):Vector.<User> {
			var removedUsers:Vector.<User> = new Vector.<User>();
			for each(var user:User in previousUsers) {
				var remove:Boolean = true;
				for each(var otherUser:User in newUsers) {
					if (otherUser.trackingID == user.trackingID) {
						remove = false;
						break;
					}
				}
				if (remove) {
					removedUsers.push(user);
					delete dictionary[user.trackingID];
				}
			}
			return removedUsers;
		}


		/**
		 * Get a list of all users
		 */
		public function get users():Vector.<User> {
			return _users
		}

		/**
		 * Get a list of the users with a tracked skeleton
		 */
		public function get usersWithSkeleton():Vector.<User> {
			return _usersWithSkeleton;
		}
		
		/**
		 * Get a list of the supported skeleton joint names
		 */ 
		public function get skeletonJointNames():Vector.<String>
		{
			return _skeletonJointNames;
		}

		//----------------------------------
		// User Frame Simulation Code
		//----------------------------------

		/**
		 * Allows for this device to disregard updates from the _context and only listen for manual User Frame updates.
		 * @param value
		 */
		public function set userSimulationMode(value:Boolean):void {
			_userSimulationMode = value;
		}

		public function get userSimulationMode():Boolean {
			return _userSimulationMode;
		}

		/**
		 * Allows for constructed UserFrames to be passed thru the device as if they were coming from the _context.
		 * This is used for simulated skeleton playback
		 * @param userFrame            Userframe to simulate
		 */
		public function simulateUserFrame(userFrame:UserFrame):void {
			processUserFrame(userFrame);
		}
	}
}