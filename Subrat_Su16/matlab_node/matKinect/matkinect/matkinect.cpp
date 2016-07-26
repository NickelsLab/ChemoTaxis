/*
	MatKinect is a streaming interface to the Kinect Depth sensing Camera for Matlab.
	Designed for scientific/engineering applications involving Matlab and the Kinect Sensor.

	This base file initializes and scans for available Kinect sensors.  This is the main interface to the adaptor dll.

	Streams live 30Hz data into Matlab from a separate acquisition thread as 16-bit grayscale frames.

	I use the win32 kinect code provided via links at the OpenKinect Website
	Zephods win32 kinect driver library
	http://openkinect.org/wiki/Getting_Started_Windows

	This Matlab Adaptor:
	Author: Gus K Lott III, PhD
	November 23, 2010
	
	Neurobiological Instrumentation Engineer
	Howard Hughes Medical Institute - Janelia Farm Research Campus
	
	Senior Engineer, YarCom Inc.
	guslott@yarcom.com

	 * Copyright (c) 2010 Gus K Lott III, PhD. 
	 *
	 * This code is licensed to you under the terms of the Apache License, version
	 * 2.0, or, at your option, the terms of the GNU General Public License,
	 * version 2.0. See the APACHE20 and GPL2 files for the text of the licenses,
	 * or the following URLs:
	 * http://www.apache.org/licenses/LICENSE-2.0
	 * http://www.gnu.org/licenses/gpl-2.0.txt
	 *
	 * If you redistribute this file in source form, modified or unmodified, you
	 * may:
	 *   1) Leave this header intact and distribute it under the same terms,
	 *      accompanying it with the APACHE20 and GPL20 files, or
	 *   2) Delete the Apache 2.0 clause and accompany it with the GPL2 file, or
	 *   3) Delete the GPL v2 clause and accompany it with the APACHE20 file
	 * In all cases you must keep the copyright notice intact and include a copy
	 * of the CONTRIB file.
	 *
	 * Binary distributions must follow the binary distribution requirements of
	 * either License.


*/

#ifdef _WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#endif

#include "mwadaptorimaq.h"
#include "matkinectAdaptor.h"
#include <Kinect-win32.h>

void initializeAdaptor(){
	
		
}
void uninitializeAdaptor(){
	//imaqkit::adaptorWarn("matkinectPropListener:debug","UnInitializeing matkinect");

}

void getAvailHW(imaqkit::IHardwareInfo* hardwareInfo){

	/*
		For each device you want to make available through your adaptor, you must
		create an IDeviceInfo object and then store the object in the IHardwareInfo
		object.  For each format supported by a device, you must create an
		IDeviceFormat object and then store the object in the IDeviceInfo object.

		IHardwareInfo -> IDeviceInfo (contains Adaptor data) -> IDeviceFormat (contains Adaptor data)
	*/

	//For each device: Device ID, Device name, supported formats, if camera files are supported

	//Steps:
	//1: Determine which devices are available through the SDK
	//2: For each device found, create an IDeviceInfo object
	//	2a: For each format supported by the device, create an IDeviceFormat Object
	//	2b: Add each device format object that you create to the IDeviceInfo object
	//3: Add the IDeviceInfo object to the IHardwareInfo object passed to this function

	
	unsigned long numCameras;

	imaqkit::IDeviceInfo * deviceInfo;
	imaqkit::IDeviceFormat * deviceFormat;

	imaqkit::adaptorWarn("matkinectPropListener:debug","MatKinect - by Gus K Lott III, PhD - November 2010 - guslott@yarcom.com");

	//Sleep(2500);
	Kinect::KinectFinder finder;
	numCameras = finder.GetKinectCount();
	//Sleep(2500);
	//numCameras = 1;

	
	//imaqkit::adaptorWarn("matkinectPropListener:debug","%d Cameras Found",numCameras);



	for (unsigned long i=0; i<numCameras; i++){
		
		deviceInfo = hardwareInfo->createDeviceInfo(i,"KinectNUI");

		deviceFormat=deviceInfo->createDeviceFormat(0,"DepthImage");
		deviceInfo->addDeviceFormat(deviceFormat,true);

		//Build List of Available Formats/Modes
		/*for (unsigned long j=0; j<8; j++){ //Format
			for (unsigned long k=0; k<8; k++){ //Mode
				if (Camera.HasVideoMode(j,k)){
					sprintf(buf,"Format %i, Mode %i",j,k);
					deviceFormat=deviceInfo->createDeviceFormat((j<<3)+k,buf);
					//TODO: Add available frame rates as adaptor data?
					//Add available format/mode to device parent
					deviceInfo->addDeviceFormat(deviceFormat,gFlag);
					gFlag=false;
				}
			}
		}*/

		//Add Available device w/ modes to parent hardware space
		hardwareInfo->addDevice(deviceInfo);
	}



}

void getDeviceAttributes(const imaqkit::IDeviceInfo* deviceInfo, 
						 const char* sourceType, 
						 imaqkit::IPropFactory* devicePropFact,
						 imaqkit::IVideoSourceInfo* sourceContainer,
						 imaqkit::ITriggerInfo* hwTriggerInfo){

    void * hProp;
	int devID = deviceInfo->getDeviceID();

	//create a video source, could eventually contain RGB as an option
	sourceContainer->addAdaptorSource("DepthImage",1);

	hProp = devicePropFact->createDoubleProperty("Motor",0,1,1);
	devicePropFact->setPropReadOnly(hProp,imaqkit::propreadonly::NEVER);
	devicePropFact->addProperty(hProp);


}

imaqkit::IAdaptor* createInstance(imaqkit::IEngine* engine, imaqkit::IDeviceInfo* deviceInfo, char* formatName){
	
	//instantiate a dcamAdaptor object and pass it back to Matlab
	imaqkit::IAdaptor* adaptor = new matkinectAdaptor(engine,deviceInfo,formatName);
	return adaptor;
}




