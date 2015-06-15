#include <string>
#include <string.h>
#include <cstddef>
#include <stdio.h>
#include "serialPort.hpp"

using namespace std;

void send_command(SerialPort *Port, char *cmd, char *recvbuff); 
int send_bin_command(SerialPort *Port, char *cmd, int len, char *recvbuff); 

int as_int(char *buff) {
	return (buff[0]&0xff)+((buff[1]&0xff)<<8);
}

int main (int argc, char *argv[]) 
{
  string portstr = std::string("/dev/rfcomm0",255);
  SerialPort *serialPort;
  serialPort = new SerialPort(portstr);
  if(serialPort->initialize() == -1)
  {
	  	perror("main");
    	return -1;
  }
  //printf("init ok.\n");

  int nr,n,nw;
  char cmd[255], recvbuff[255];

  printf("Version\n");
  cmd[0] = 0x01; // send version
  nr = send_bin_command(serialPort,cmd,1,recvbuff);

  printf("LEDs\n");
  cmd[0] = 0x18; cmd[1]=0xFF; cmd[2]=0xFF; // setLEDS, ringmask, body_frontmask
  nr = send_bin_command(serialPort,cmd,3,recvbuff);

  sleep(1);
  cmd[0] = 0x18; cmd[1]=0x00; cmd[2]=0x00; // setLEDS, ringmask, body_frontmask
  nr = send_bin_command(serialPort,cmd,3,recvbuff);

  printf("SendSteps\n");
  cmd[0] = 0x14; // send steps
  nr = send_bin_command(serialPort,cmd,1,recvbuff);

  printf("RecvVel\n");
  cmd[0] = 0x13; cmd[1]=0x64; cmd[2]=0x00; cmd[3]=0x64; cmd[4]=0x00;
  nr = send_bin_command(serialPort,cmd,5,recvbuff);
  sleep(1);

  //cmd[0] = 0x13; cmd[1]=0x00; cmd[2]=0x00; cmd[3]=0x00; cmd[4]=0x00;
  cmd[0] = 0x15;
  nr = send_bin_command(serialPort,cmd,1,recvbuff);

  printf("ReadFloorSensors\n");
  cmd[0] = 0x22; 
  for (int i=0;i<2;i++){
     nr = send_bin_command(serialPort,cmd,1,recvbuff);
	 printf("l = %d, c=%d, r=%d\n",
			 as_int(&recvbuff[0]),
			 as_int(&recvbuff[2]),
			 as_int(&recvbuff[4]));
  }
     
  cmd[0] = 0x42; // nonsensical
  nr = send_bin_command(serialPort,cmd,1,recvbuff);

  cmd[0] = 0x42; // nonsensical
  nr = send_bin_command(serialPort,cmd,1,recvbuff);


  return 0;
}

void send_command(SerialPort *Port,  char *cmd, char *recvbuff) {
  int nw,n = strlen(cmd);
  //printf("Sending '%s' as cmd\n",cmd);
  nw=Port->sendCharArray(cmd,n); // send command
  Port->recvCharArray(recvbuff,255); // receive response
  //printf("Got: '%s' as response\n",recvbuff);
  //sleep(1);
} 

int send_bin_command(SerialPort *Port,  char *cmd, int len, char *recvbuff) {
  int nw,nr;
  /*
  printf("send_bin_command:Sending ");
  for (int i=0;i<len;i++) printf("'%02x', ",0xff&cmd[i]);
  printf(" as command\n");
  */

  nw=Port->sendCharArray(cmd,len); // send command
  nr=Port->recvBinaryArray(recvbuff,255); // receive response
  /*
  printf("send_bin_command:Read %d bytes as response: ",nr);
  for (int i=0;i<nr;i++) printf("'%02x', ",0xff&recvbuff[i]);
  printf(".\n");
  */
  return nr;
 }

