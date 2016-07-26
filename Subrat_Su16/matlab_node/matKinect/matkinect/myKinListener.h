#ifndef MYKINLISTENER_H
#define MYKINLISTENER_H

#include <Kinect-win32.h>
class matkinectAdaptor;

class MyKinListener : public Kinect::KinectListener {

public:

	matkinectAdaptor * adaptor;

	void KinectDisconnected(Kinect::Kinect *K);
	void DepthReceived(Kinect::Kinect *K);
	void ColorReceived(Kinect::Kinect *K);
	void AudioReceived(Kinect::Kinect *K);

};


#endif //MYKINLISTENER_H