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

#include "serialPort.hpp"
#include <cstdio>   /* Standard input/output definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <cerrno>   /* Error number definitions */
#include <cstring>
#include <cstddef>
#include <sys/time.h>

#define LEN_INT_MESSAGE 2

SerialPort::SerialPort(std::string &serialPort)
  :serialPort(serialPort)
{}

SerialPort::~SerialPort()
{
  tcsetattr(this->fileDescriptor, TCSANOW, &termios_backup);
  tcflush(this->fileDescriptor, TCOFLUSH);
  tcflush(this->fileDescriptor, TCIFLUSH);
  close(this->fileDescriptor);
  this->fileDescriptor = -1;
}

int SerialPort::initialize()
{
  //this->fileDescriptor = open(this->serialPort.c_str(),
  //                            O_RDWR|O_NOCTTY|O_NONBLOCK);
  this->fileDescriptor = open(this->serialPort.c_str(),
                              O_RDWR|O_NOCTTY);
  if(this->fileDescriptor == -1)
  {
    this->errorDescription = std::string(strerror(errno));
    errorDescription += "  Path: " + this->serialPort;
    return -1;
  }

  struct termios conf;

  if(tcgetattr(this->fileDescriptor, &conf))
  {
    this->errorDescription = std::string(strerror(errno));
    errorDescription += "  Path: " + this->serialPort;
    return -1;
  }
  memcpy(&this->termios_backup, &conf, sizeof(struct termios));

  //---------------------- Configure the speed
  if(cfsetispeed(&conf, B115200))
  {
    this->errorDescription = std::string(strerror(errno));
    errorDescription += "  Path: " + this->serialPort;
    return -1;
  }

  if(cfsetospeed(&conf, B115200))
  {
    this->errorDescription = std::string(strerror(errno));
    errorDescription += "  Path: " + this->serialPort;
    return -1;
  }

  // similar to cfmakeraw()
  conf.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP
                    |INLCR|IGNCR|ICRNL|IXON);
  conf.c_oflag &= ~OPOST;
  conf.c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
  conf.c_cflag &= ~(CSIZE|PARENB);
  conf.c_cflag |= CS8;

  // Set the new conf for the port...
  if(tcsetattr(this->fileDescriptor, TCSANOW, &conf))
  {
    this->errorDescription = std::string(strerror(errno));
    errorDescription += "  Path: " + this->serialPort;
    return -1;
  }
  tcflush(this->fileDescriptor, TCOFLUSH);
  tcflush(this->fileDescriptor, TCIFLUSH);

  return 0;
}

int
SerialPort::recvInt() const
{
  char message[2];
  fd_set readfds;

  FD_ZERO(&readfds);
  FD_SET (this->fileDescriptor , &readfds);
  select(this->fileDescriptor+1, &readfds, NULL, NULL, NULL);
  while(read(this->fileDescriptor, message, 1) <= 0);

  FD_ZERO(&readfds);
  FD_SET (this->fileDescriptor , &readfds);
  select(this->fileDescriptor+1, &readfds, NULL, NULL, NULL);
  while(read(this->fileDescriptor, message+1, 1) <= 0);

  return (message[1] << 8) | (message[0] & 0xFF);
}

unsigned
SerialPort::recvUnsigned() const
{
  char message[2];
  fd_set readfds;

  FD_ZERO(&readfds);
  FD_SET (this->fileDescriptor , &readfds);
  select(this->fileDescriptor+1, &readfds, NULL, NULL, NULL);
  while(read(this->fileDescriptor, message, 1) <= 0);

  FD_ZERO(&readfds);
  FD_SET (this->fileDescriptor , &readfds);
  select(this->fileDescriptor+1, &readfds, NULL, NULL, NULL);
  while(read(this->fileDescriptor, message+1, 1) <= 0);

  return ((message[1] & 0xFF) << 8) | (message[0] & 0xFF);
}

char
SerialPort::recvChar() const
{
  char message = -1;
  fd_set readfds;
  struct timeval timeout;
  int retval;

  timeout.tv_sec=1;
  timeout.tv_usec=0;

  FD_ZERO(&readfds);
  FD_SET (this->fileDescriptor , &readfds);
  retval=select(this->fileDescriptor+1, &readfds, NULL, NULL, &timeout);
  if (retval==-1)
	  perror("SerialPort::recvChar::select()");
  else if (retval) 
	  while(read(this->fileDescriptor, &message, 1) <= 0);
  else
	  printf("Timeout waiting for data\n"); 

  return message;
}

int
SerialPort::recvUnsignedCharArray(unsigned char* const array,
                                  unsigned length) const
{
  fd_set readfds;
  FD_ZERO(&readfds);
  FD_SET (this->fileDescriptor , &readfds);

  int i, num_reads;
  for(i = num_reads = 0; length-i > 0; i+=num_reads)
  {
    select(this->fileDescriptor+1, &readfds, NULL, NULL, NULL);
    if(FD_ISSET(this->fileDescriptor ,&readfds))
    {
      num_reads = read(this->fileDescriptor, array+i, length-i);
    }
    else
    {
      return -1;
    }
  }
  return 0;
}

int
SerialPort::recvCharArray(char* const array,
                                  unsigned length) const
{
	int num_read=0;
	for (unsigned int i=0;i<length;i++) {
		array[i] = recvChar();
		if (array[i] != -1) num_read++;
		//printf("Got a '%d', %d chars so far...\n",array[i],num_read);
		if (array[i]==10) break; // Responses end with CR,LF
		}

	if (array[num_read-1] == 10 && array[num_read-2]==13) {
		array[num_read-2]='\0';
		array[num_read-1]='\0';
		num_read -= 2;
	}
	return num_read;
}

int
SerialPort::sendCharArray(char* const array,
                                  unsigned length) const
{
	int nw,num_write=0;
	for (unsigned int i=0;i<length;i++) {
		nw = sendChar(array[i]);
		//printf("Sent '%c', rtn=%d, %d bytes written so far\n",array[i],nw,num_write);
		//fflush(stdout);
		if (num_write==-1) { 
			printf("Error: %s\n",strerror(errno));
		} else
		num_write += nw;
	}
	// This should work, but freezes epuck
  	//num_write = write(this->fileDescriptor, &array, length);
	return num_write;
}


int
SerialPort::sendUnsignedCharArray(unsigned char* const array,
                                  unsigned length) const
{
	int num_write;
  	num_write = write(this->fileDescriptor, &array, length);
	return num_write;
}


void SerialPort::sendInt(int message) const
{
  //TODO: verificar o tamanho do inteiro (check the entire size?)
  char chMessage[2];
  chMessage[0] = message & 0xFF;
  chMessage[1] = (message>>8) & 0xFF;

  write(this->fileDescriptor, chMessage, 2);
}

int SerialPort::sendChar(char message) const
{
  int tmp = 0;
  tmp = write(this->fileDescriptor, &message, 1);
  return tmp;
}
