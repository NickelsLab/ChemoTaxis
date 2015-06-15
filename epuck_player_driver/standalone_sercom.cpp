#include <string>
#include <string.h>
#include <cstddef>
#include <stdio.h>
#include "serialPort.hpp"

using namespace std;

void send_command(SerialPort *Port, char *cmd, char *recvbuff); 


int main (int argc, char *argv[]) 
{
  string portstr = std::string("/dev/rfcomm3",255);
  SerialPort *serialPort;
  serialPort = new SerialPort(portstr);
  if(serialPort->initialize() == -1)
  {
	  	perror("main");
		return -1;
  }
  //printf("init ok.\n");

  int n,nw;
  char cmd[255], recvbuff[255];

  serialPort->flushInput(); // clear out any outstanding repsonses
  send_command(serialPort,(char *)"f,1\n",recvbuff);
  usleep(500);
  send_command(serialPort,(char *)"f,2\n",recvbuff);

  send_command(serialPort,(char *)"v\n",recvbuff);
  serialPort->recvCharArray(recvbuff,255); // receive response
  //printf("Got: '%s' as response2\n",recvbuff);

  send_command(serialPort,(char *)"e\n",recvbuff);
  send_command(serialPort,(char *)"d,100,100\n",recvbuff);
  
  //sleep(5);

  for (int j=0; j<10;j++) {
	  send_command(serialPort,(char *)"m\n",recvbuff);
	  int lines[5];
	  int nr = sscanf(recvbuff,"m,%d,%d,%d,%d,%d",
			  &lines[0],&lines[1],&lines[2],&lines[3],&lines[4]);
	  printf("Center line is %d\n",lines[1]);
  }


  send_command(serialPort,(char *)"d,0,0\n",recvbuff);

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

