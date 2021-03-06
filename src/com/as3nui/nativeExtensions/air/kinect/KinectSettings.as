/**
 *
 * User: rgerbasi
 * Date: 2/22/12
 * Time: 5:27 PM
 */
package com.as3nui.nativeExtensions.air.kinect {
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;

	import flash.geom.Point;

	public class KinectSettings  {

		private var _depthEnabled:Boolean 					= false;
		private var _depthResolution:Point 					= CameraResolution.RESOLUTION_320_240;
		private var _depthShowUserColors:Boolean 			= false;
		private var _depthEnableNearMode:Boolean			= false;
		private var _depthMirrored:Boolean 					= true;

		private var _rgbEnabled:Boolean 					= false;
		private var _rgbResolution:Point 					= CameraResolution.RESOLUTION_640_480;
		private var _rgbMirrored:Boolean 					= true;

		private var _userEnabled:Boolean 					= false;
		private var _userMirrored:Boolean 					= true;
		private var _skeletonEnabled:Boolean 				= false;
		private var _skeletonMirrored:Boolean 				= true;

		private var _pointCloudEnabled:Boolean				= false;
		private var _pointCloudResolution:Point				= CameraResolution.RESOLUTION_320_240;
		private var _pointCloudIncludeRGB:Boolean			= false;
		private var _pointCloudDensity:uint					= 1;
		private var _pointCloudMirrored:Boolean				= true;

		private var _userMaskEnabled:Boolean				= false;
		private var _userMaskResolution:Point				= CameraResolution.RESOLUTION_320_240;
		private var _userMaskMirrored:Boolean				= true;


		public function KinectSettings() {
		}

		public function get depthEnabled():Boolean {
			return _depthEnabled;
		}

		public function set depthEnabled(value:Boolean):void {
			_depthEnabled = value;
		}

		public function get depthResolution():Point {
			return _depthResolution;
		}

		public function set depthResolution(value:Point):void {
			_depthResolution = value;
		}

		public function get depthShowUserColors():Boolean {
			return _depthShowUserColors;
		}

		public function set depthShowUserColors(value:Boolean):void {
			_depthShowUserColors = value;
		}
		
		public function get depthEnableNearMode():Boolean {
			return _depthEnableNearMode;
		}
		
		public function set depthEnableNearMode(value:Boolean):void {
			_depthEnableNearMode = value;
		}

		public function get depthMirrored():Boolean {
			return _depthMirrored;
		}

		public function set depthMirrored(value:Boolean):void {
			_depthMirrored = value;
		}

		public function get rgbEnabled():Boolean {
			return _rgbEnabled;
		}

		public function set rgbEnabled(value:Boolean):void {
			_rgbEnabled = value;
		}

		public function get rgbResolution():Point {
			return _rgbResolution;
		}

		public function set rgbResolution(value:Point):void {
			_rgbResolution = value;
		}

		public function get rgbMirrored():Boolean {
			return _rgbMirrored;
		}

		public function set rgbMirrored(value:Boolean):void {
			_rgbMirrored = value;
		}

		public function get userEnabled():Boolean {
			return _userEnabled;
		}

		public function set userEnabled(value:Boolean):void {
			_userEnabled = value;
		}

		public function get userMirrored():Boolean {
			return _userMirrored;
		}

		public function set userMirrored(value:Boolean):void {
			_userMirrored = value;
		}

		public function get skeletonEnabled():Boolean {
			return _skeletonEnabled;
		}

		public function set skeletonEnabled(value:Boolean):void {
			_skeletonEnabled = value;
		}

		public function get skeletonMirrored():Boolean {
			return _skeletonMirrored;
		}

		public function set skeletonMirrored(value:Boolean):void {
			_skeletonMirrored = value;
		}

		public function get pointCloudEnabled():Boolean {
			return _pointCloudEnabled;
		}

		public function set pointCloudEnabled(value:Boolean):void {
			_pointCloudEnabled = value;
		}

		public function get pointCloudResolution():Point {
			return _pointCloudResolution;
		}

		public function set pointCloudResolution(value:Point):void {
			_pointCloudResolution = value;
		}

		public function get pointCloudIncludeRGB():Boolean {
			return _pointCloudIncludeRGB;
		}

		public function set pointCloudIncludeRGB(value:Boolean):void {
			_pointCloudIncludeRGB = value;
		}

		public function get pointCloudDensity():uint {
			return _pointCloudDensity;
		}

		public function set pointCloudDensity(value:uint):void {
			_pointCloudDensity = value;
		}

		public function get pointCloudMirrored():Boolean {
			return _pointCloudMirrored;
		}

		public function set pointCloudMirrored(value:Boolean):void {
			_pointCloudMirrored = value;
		}

		public function get userMaskEnabled():Boolean {
			return _userMaskEnabled;
		}

		public function set userMaskEnabled(value:Boolean):void {
			_userMaskEnabled = value;
		}

		public function get userMaskResolution():Point {
			return _userMaskResolution;
		}

		public function set userMaskResolution(value:Point):void {
			_userMaskResolution = value;
		}

		public function get userMaskMirrored():Boolean {
			return _userMaskMirrored;
		}

		public function set userMaskMirrored(value:Boolean):void {
			_userMaskMirrored = value;
		}

		public function dispose():void {
		}
	}
}