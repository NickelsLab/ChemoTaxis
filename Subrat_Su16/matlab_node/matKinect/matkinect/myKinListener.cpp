#include "myKinListener.h"
#include "matkinectAdaptor.h"


void MyKinListener::KinectDisconnected(Kinect::Kinect *K) {
};
void MyKinListener::DepthReceived(Kinect::Kinect *K) {

	K->ParseDepthBuffer();
	//imaqkit::adaptorWarn("matkinectAdaptor:debug","In Listener");

	int imWidth = 640, imHeight = 480;

	if (adaptor->isSendFrame()){
		//get frame type & dimensions
		imaqkit::frametypes::FRAMETYPE frameType = adaptor->getFrameType();
		imaqkit::IAdaptorFrame* frame = adaptor->getEngine()->makeFrame(frameType,imWidth,imHeight); //Get a frame object
		frame->setImage(K->mDepthBuffer,imWidth,imHeight,0,0); //Copy data from buffer into frame object
		frame->setTime(imaqkit::getCurrentTime()); //Set image's timestamp
		adaptor->getEngine()->receiveFrame(frame); //Send frame object to engine.
	} //isSendFrame
	//Increment the frame count
	adaptor->incrementFrameCount();
	


};
void MyKinListener::ColorReceived(Kinect::Kinect *K) {
	//Currently do nothing
	//K->ParseColorBuffer();
};
void MyKinListener::AudioReceived(Kinect::Kinect *K) {
};