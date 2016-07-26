/* Definition of the matkinect interface for acquisition from a given camera
	This is the Image Acquisition Adaptor Class

	Author: Gus K Lott III, PhD
	Dec 28, 2008
	
	Neurobiological Instrumentation Engineer
	Howard Hughes Medical Institute - Janelia Farm Research Campus
	lottg@janelia.hhmi.org
	571.209.4362
*/

#ifndef __MATKINECT_ADAPTOR_HEADER__
#define __MATKINECT_ADAPTOR_HEADER__

#include <windows.h>
#include "mwadaptorimaq.h"
#include <Kinect-win32.h>
class MyKinListener;


class matkinectAdaptor : public imaqkit::IAdaptor {
	
public:

	//Constructor and Destructor
	matkinectAdaptor(imaqkit::IEngine* engine, imaqkit::IDeviceInfo* deviceInfo, const char* formatName);
	virtual ~matkinectAdaptor();

	//Adaptor and Image Information Functions
	virtual const char* getDriverDescription() const;
	virtual const char* getDriverVersion() const;
	virtual int getMaxWidth() const;
	virtual int getMaxHeight() const;
	virtual int getNumberOfBands() const;
	virtual imaqkit::frametypes::FRAMETYPE getFrameType() const;

	//Image Acquisition Functions
	virtual bool openDevice();
	virtual bool closeDevice();
	virtual bool startCapture();
	virtual bool stopCapture();

	int devId;
	double motorPos;

	MyKinListener * listener;
	Kinect::Kinect * kin;

	bool acquireFlag;


private:

	imaqkit::IPropContainer* _enginePropContainer;
	imaqkit::IDeviceInfo* _di;
	imaqkit::ICriticalSection* _grabSection;

	HANDLE _acquireThread; //Thread variable
	DWORD _acquireThreadID; //Thread ID returned by Windows
	static DWORD WINAPI acquireThread(void* param); //Declaration of acquisition thread function

};

#endif