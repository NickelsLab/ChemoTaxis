/*Property Listener Implementation
	


*/

#ifndef __MATKINECT_PROP_LISTENER_HEADER__
#define __MATKINECT_PROP_LISTENER_HEADER__

#include "mwadaptorimaq.h"  
#include "matkinectAdaptor.h"
#include "matkinectimaq.h"


class matkinectPropListener : public imaqkit::IPropPostSetListener{
public:
	matkinectPropListener(matkinectAdaptor* parent): _parent(parent) {};
    virtual ~matkinectPropListener() {};
	virtual void notify(imaqkit::IPropInfo* propertyInfo, void* newValue);

private:
	//virtual void applyValue(void);
	matkinectAdaptor* _parent;
	imaqkit::IPropInfo* _propInfo;
	int _lastIntValue;
	double _lastDoubleValue;
	char* _lastStrValue;
	int * _lastIntArrayValue;
};

#endif