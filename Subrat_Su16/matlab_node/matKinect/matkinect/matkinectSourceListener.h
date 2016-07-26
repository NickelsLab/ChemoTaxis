#ifndef __MATKINECT_SOURCE_LISTENER_HEADER__
#define __MATKINECT_SOURCE_LISTENER_HEADER__

#include "mwadaptorimaq.h"  
#include "matkinectAdaptor.h"


class matkinectSourceListener : public imaqkit::IPropPostSetListener
{
public:
	matkinectSourceListener(matkinectAdaptor* parent) : _parent(parent) {};
	virtual ~matkinectSourceListener(void){};
	virtual void notify(imaqkit::IPropInfo* propertyInfo, void* newValue);

private:
	virtual void applyValue(void);
	matkinectAdaptor* _parent;
	int _source;

};

#endif