
#include "matkinectSourceListener.h"

void matkinectSourceListener::notify(imaqkit::IPropInfo *propertyInfo, void *newValue) {

	if (newValue){
		_source = *static_cast<const int*>(newValue);

		if (_parent->isOpen()) {
			applyValue();
		}
	}
	

}

void matkinectSourceListener::applyValue(void){

	bool wasAcquiring = _parent->isAcquiring();
	if(wasAcquiring){
		_parent->stop();
	}

	if(wasAcquiring) {
		_parent->restart();
	}

}