/* Copyright 2008 Renato Florentino Garcia <fgar.renato@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2, as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "epuckInterface.hpp"

const float EpuckInterface::EPUCK_DIAMETER = 0.07;

EpuckInterface::EpuckInterface(const SerialPort* const serialPort)
  :serialPort(serialPort)
{}

void
EpuckInterface::SendRequest(Request request) const
{
  switch(request) {
	  case SET_VEL:
		  // have to pass in d,velR,velL as string - see
		  // epuckPosition2d.cpp:812
		  break;
	  case RST_STEPS:
		  this->serialPort->sendCharArray((char *)"p,0,0\n",6); // reset odom
		  break;
	  case GET_STEPS:
		  this->serialPort->sendCharArray((char *)"q\n",2); // reset odom
		  break;
	  case STOP_MOTORS:
		  this->serialPort->sendCharArray((char *)"s\n",2);
		  break;
	  case GET_IR_PROX:
		  this->serialPort->sendCharArray((char *)"n\n",2);
		  break;
	  case SET_LED_POWER:
		  // have to parse ringLEDmsg and frontBodyLEDmsg
		  break;
	  case GET_LINE_SENSOR:
		  this->serialPort->sendCharArray((char *)"m\n",2);
		  break;
	  case CAL_IR_PROX:
		  char buff[256];
		  this->serialPort->sendCharArray((char *)"k\n",2);
		  this->serialPort->recvCharArray(buff,256); // receive response 
		  this->serialPort->recvCharArray(buff,256); // receive response 
		  break;
	  case CONFIG_CAMERA:
	  case GET_CAMERA_IMG:
	  default:
		  PLAYER_WARN1("Epuck:: Unhandled message %x",request);
		  break;
  }
}
