/* Implementation of the matkinect interface for acquisition from a given camera
	This is the Image Acquisition Adaptor Class that is created when you execute "vi = videoinput('matkinect');"b

	Author: Gus K Lott III, PhD
	November 23, 2010
	
	Neurobiological Instrumentation Engineer
	Howard Hughes Medical Institute - Janelia Farm Research Campus
	
	Senior Engineer, YarCom Inc.
	guslott@yarcom.com

*/

#include "matkinectimaq.h"
#include "matkinectAdaptor.h"
#include "matkinectPropListener.h"
#include "matkinectSourceListener.h"
#include "matkinectDeviceFormat.h"
#include "myKinListener.h"

#include <stdio.h>

//Class Constructor
matkinectAdaptor::matkinectAdaptor(imaqkit::IEngine* engine, imaqkit::IDeviceInfo* deviceInfo, const char* formatName):imaqkit::IAdaptor(engine){

	//Connect the camera object to the indicated camera with the indicated format
	
	
	devId = deviceInfo->getDeviceID();
	kin = 0;
	motorPos = 1;

	//setup listeners
	_enginePropContainer = getEngine()->getAdaptorPropContainer();
	_enginePropContainer->addListener("SelectedSourceName", new matkinectSourceListener(this));

	imaqkit::IPropContainer* adaptorPropContainer = getEngine()->getAdaptorPropContainer();
	int numDeviceProps = adaptorPropContainer->getNumberProps();
	const char **devicePropNames = new const char*[numDeviceProps];
	adaptorPropContainer->getPropNames(devicePropNames);

	for (int i = 0; i < numDeviceProps; i++){

         // Get the property information object.
         imaqkit::IPropInfo* propInfo = adaptorPropContainer->getIPropInfo(devicePropNames[i]);

         // Check to see whether the property is device-specific. Do not create
         // create property listeners for non device-specific properties such
         // as 'Parent' and 'Tag'.
         if (propInfo->isPropertyDeviceSpecific()) {
             adaptorPropContainer->addListener(devicePropNames[i], new matkinectPropListener(this));
         }
     }
	delete [] devicePropNames;
	_grabSection = imaqkit::createCriticalSection();

	//imaqkit::adaptorWarn("matkinectAdaptor:debug","In Constructor");
	


}

//Class Destructor
matkinectAdaptor::~matkinectAdaptor(){
	//When the C1394Camera Object is destroyed, it cleans itself up (Stops acquisition and frees resources)
}

//Device Driver information functions
const char* matkinectAdaptor::getDriverDescription() const{
	return "matkinect_skeleton";
}
const char* matkinectAdaptor::getDriverVersion() const{
	return "0.1";
}

//Image data information functions
int matkinectAdaptor::getMaxWidth() const { 
	unsigned long pWidth, pHeight;
	pWidth = 640;
	pHeight = 480;
	return (int)pWidth; }

int matkinectAdaptor::getMaxHeight() const { 
	unsigned long pWidth, pHeight;
	pWidth = 640;
	pHeight = 480;
	return pHeight; }

int matkinectAdaptor::getNumberOfBands() const { 
	//Image Acquisition toolbox software only supports image data with 1 or 3 bands
	return 1; //this is an unfortunate limitation
}

imaqkit::frametypes::FRAMETYPE matkinectAdaptor::getFrameType() const {
	//return imaqkit::frametypes::MONO16;
	return imaqkit::frametypes::MONO12; //its really only 11 bits... still stored in a short regardless
}

//Image acquisition functions
bool matkinectAdaptor::openDevice() { 

	//If device is already open, return true.
	if (isOpen()) return true;

	//imaqkit::adaptorWarn("matkinectAdaptor:debug","Constructing Acquisition Thread");
	//Create acquisition thread
	acquireFlag = true;
	_acquireThread = CreateThread(NULL,0,acquireThread,this,0,&_acquireThreadID);
	if ( _acquireThread == NULL ){closeDevice();return false;}
	
	//Wait for thread to create message queue.
	while(PostThreadMessage(_acquireThreadID, WM_USER+1,0,0) == 0) 
		Sleep(1);

	return true; 
}

bool matkinectAdaptor::closeDevice() { 
	//If the device is not open, return.
	if(!isOpen()) return true;

	//Terminate and close the acquisition thread.
	acquireFlag = false;
	if(_acquireThread){
		// Send WM_QUIT message to thread
		PostThreadMessage(_acquireThreadID, WM_QUIT, 0,0);

		//Give the thread a chance to finish
		WaitForSingleObject(_acquireThread, 1000);

		//Close thread handle
		CloseHandle(_acquireThread);
		_acquireThread = NULL;
	}

	return true; 
}
bool matkinectAdaptor::startCapture() { 
	//Check if device is already acquiring frames
	if (isAcquiring()) return false;

	//imaqkit::adaptorWarn("matkinectAdaptor:debug","Start Acquisition");

	//kin->AddListener(listener);
	//Send start message to acquisition thread
	PostThreadMessage(_acquireThreadID, WM_USER,0,0);

	return true; 
}

bool matkinectAdaptor::stopCapture() { 

	//If the device is not acquiring data, return
	if (!isOpen()) return true;
	acquireFlag = false;
	
	//TODO: Must wait until acquisition is done to exit this function (assume this is to fire stopfcn of object)
	//kin->RemoveListener(listener);
	
	
	return true; 
}

DWORD WINAPI matkinectAdaptor::acquireThread(void* param){

	matkinectAdaptor* adaptor = reinterpret_cast<matkinectAdaptor*>(param);
	MSG msg;
	
	//Connect to the kinect
	Kinect::KinectFinder finder;
	adaptor->kin = finder.GetKinect(adaptor->devId);
	double tempMotorPos = adaptor->motorPos;
	
	//Create the listener
	adaptor->listener = new MyKinListener();
	adaptor->listener->adaptor = adaptor;
	
	unsigned int imWidth = adaptor->getMaxWidth();
	unsigned int imHeight = adaptor->getMaxHeight();

	// Set the thread priority. 
    //SetThreadPriority(GetCurrentThread(),THREAD_PRIORITY_TIME_CRITICAL);
	//imaqkit::adaptorWarn("matkinectAdaptor:debug","Entry to Acquisition Thread - width %i height %i",imWidth,imHeight);

	while(GetMessage(&msg,NULL,0,0) > 0){
		switch(msg.message){
			case WM_USER:
				//The Frame Acquisition Loop code goes here.
				//imaqkit::adaptorWarn("matkinectAdaptor:debug","In Acquisition Case for WM_USER");
	
				//When the user requests, attach to the depth buffer
				adaptor->kin->AddListener(adaptor->listener);
				
				//Check if a frame needs to be acquired
				while(adaptor->isAcquisitionNotComplete() & adaptor->acquireFlag){
										
					if (adaptor->motorPos != tempMotorPos){
						adaptor->kin->SetMotorPosition(adaptor->motorPos);
						tempMotorPos = adaptor->motorPos;
					}
					Sleep(10);	
					//At this point, the listener is being called in the API thread and
					// pumping the kinect's frames back to matlab
					
					
				}//While Frame Acq Loop

				adaptor->kin->RemoveListener(adaptor->listener);

				break;
		}//While message is not WM_QUIT = 0
	}
	
	delete adaptor->listener;
	adaptor->kin = 0;

	//imaqkit::adaptorWarn("matkinectAdaptor:debug","Leaving Acquisition Thread");
	return 0;
}
