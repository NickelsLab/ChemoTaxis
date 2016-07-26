#include "matkinectPropListener.h"


void matkinectPropListener::notify(imaqkit::IPropInfo* propertyInfo, void* newValue){

	if (newValue) {
		_propInfo = propertyInfo;

		switch(_propInfo->getPropertyStorageType()){
			case imaqkit::propertytypes::DOUBLE:
				_lastDoubleValue = *reinterpret_cast<double*>(newValue);
				break;
			case imaqkit::propertytypes::INT:
                _lastIntValue = *reinterpret_cast<int*>(newValue);
                break;
			case imaqkit::propertytypes::STRING:
                _lastStrValue = reinterpret_cast<char*>(newValue);
                break;
			case imaqkit::propertytypes::INT_ARRAY:
                _lastIntArrayValue = reinterpret_cast<int*>(newValue);
                break;

		}
	}

	const char * propName = propertyInfo->getPropertyName();
	int propID = 0;

	if (!strcmp("Motor",propName)) propID = 1;
	
	switch (propID){
		case 1://Motor control in the kinect
			if (_lastDoubleValue<0) _lastDoubleValue = 0;
			if (_lastDoubleValue>1) _lastDoubleValue = 1;
			
			_parent->motorPos = _lastDoubleValue;

			break;
	}


	//imaqkit::adaptorWarn("matkinectPropListener:debug","In Property listener. PropertyID: %s\n",propertyInfo->getPropertyName());
}
