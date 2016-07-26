

#include "ros/ros.h"
#include "std_msgs/String.h"
#include "turtlesim/Pose.h"
#include <string>
#include <iostream>
#include <geometry_msgs/Twist.h>
#include <signal.h>
#include <termios.h>
#include <stdio.h>
#include <std_srvs/Empty.h>
#include <turtlesim/TeleportAbsolute.h>




//virutal keys can be found at: http://www.quickmacros.com/help/Tables/IDP_VIRTUALKEYS.html

#define KEYCODE_R 0x43 //test trial_ lots of conflicting stuff on keycodes.
#define KEYCODE_P 0x50 //this is the P key
#define KEYCODE_B 0x42  //This is the B key.
#define KEYCODE_Q 0x71 //Test trial_should quit the teleop.


class TeleopTurtle
{
public:
  TeleopTurtle();
  void patrolLoop();
  void baseLoop();
// private:
  ros::NodeHandle nh_;
  ros::NodeHandle n; //Deals with the teleport client service...
  double linear_, angular_, l_scale_, a_scale_;
  ros::Publisher twist_pub_;
  //Should initialize the client here maybe for scope issues?  
};

TeleopTurtle::TeleopTurtle():
  linear_(0),
  angular_(0),
  l_scale_(4.0),
  a_scale_(4.0)
{
  nh_.param("scale_angular_moded", a_scale_, a_scale_);
  nh_.param("scale_linear_moded", l_scale_, l_scale_);

  twist_pub_ = nh_.advertise<geometry_msgs::Twist>("turtle1/cmd_vel", 1);
  //Should call a client and deal with scoping issues.

  

}

//right now, Have no clue what this is doing...
//
int kfd = 0;
struct termios cooked, raw;
void quit(int sig)
{
  (void)sig;
  tcsetattr(kfd, TCSANOW, &cooked);
  ros::shutdown();
  exit(0);
}



/**
 * This tutorial demonstrates simple receipt of messages over the ROS system.
 */
 void patrolMode(){
  
  //bool dirty;
  std::cout<<"In Patrol Mode function\n";
  TeleopTurtle teleop_turtle;
    signal(SIGINT,quit);
    teleop_turtle.patrolLoop();
 }


void returnToBase(){
  std::cout<<"In RTB function\n";
  std::cout<<"In Patrol Mode function\n";
  TeleopTurtle teleop_turtle;
    signal(SIGINT,quit);
    teleop_turtle.baseLoop();
}

void locationCallBack(const turtlesim::Pose::ConstPtr& msg){
  std::cout<<"("<<msg->x<<", "<<msg->y<<") -> Angle = "<<msg->theta<<"\n";
  return;
}


static std::string modeMsg = "";

void chatterCallback(const std_msgs::String::ConstPtr& msg)
{
  if (msg->data == modeMsg){
    return;
  } else {
  std::cout<<"...in chatterCallBack\n";
  modeMsg = msg->data;
  std::cout<<"mode msg = "<<modeMsg<<"\n";
  return;
  }
  return;
  //ros::NodeHandle n;
  //ros::Subscriber lis = n.subscribe("/turtle1/pose", 1, locationCallBack);

  //ros::ServiceClient reset = n.serviceClient<std_srvs::Empty>("reset");
  //ros::ServiceClient teleport = n.serviceClient<turtlesim::TeleportAbsolute>("teleport");

  //std_srvs::Empty empty;
  //turtlesim::TeleportAbsolute tele;

  //turtlesim::TeleportAbsoluteRequest_<float> a(0);
  //turtlesim::TeleportAbsoluteRequest_<float> b(0);
  //turtlesim::TeleportAbsoluteRequest_<float> c(0);

  //turtlesim::TeleportAbsolute::Request(turtlesim::TeleportAbsoluteRequest_<float>(0,0,0));
  //tele.turtlesim::TeleportAbsolute::Request;
  //turtlesim::TeleportAbsolute tele(a,b,c);


  if (msg->data == "P"){
    //std::cout<<" This is P mode\n";
  }

  while (msg->data == "P"){

    //std::cout<<"Living the P-mode lifestyle\n";
   // patrolMode();


    return;

  }

  while (msg->data == "B"){
    std::cout<<"I have to return to base now\n";
    std::cout<<"\n\n\n\n";
    std::cout<<"tele--port---ing....\n";
    
    //teleport.call(tele);

    //reset.call(empty);
    //tele.request.a = 0;
    //tele.request.b = 0;
    //tele.request.c= 0;
    //(0,0,0);


    //returnToBase();
    return;
  }
  if (msg-> data != "B" || msg->data != "P"){
    std::cout<<"unable to understand command: exiting....\n";
    std::cout<<msg->data<<"\n";
    return;
  }
  
}

int main(int argc, char **argv)
{
  std::string mode = "";




  

  ros::init(argc, argv, "controller");
  // ros::init(argc, argv, "teleop_turtle");
  // ros::init(argc, argv, "/turtle1/pose");

  ros::NodeHandle n;
  ros::Rate loop_rate(10);
  ros::Subscriber modePicker = n.subscribe("userInputToModeTopic", 10, chatterCallback);
  std::cout<<modeMsg<<"\n";
  ros::spinOnce();
  

  return 0;
}












void TeleopTurtle::patrolLoop(){
  ros::Rate loop_rate(10);
  linear_=angular_=0;
  tcgetattr(kfd, &cooked);
  memcpy(&raw, &cooked, sizeof(struct termios));
  raw.c_lflag &=~ (ICANON | ECHO);

  geometry_msgs::Twist twist;
    linear_ = 1.0;
    twist.angular.z = a_scale_*angular_;
    twist.linear.x = l_scale_*linear_;
    twist_pub_.publish(twist);
    ros::spinOnce();
    loop_rate.sleep(); 
    //std::this_thread::sleep_for(std::chrono::milliseconds(10));
    angular_ = 5.0;
    linear_ = 1.0;
    twist.angular.z = a_scale_*angular_;
    twist.linear.x = l_scale_*linear_;
    twist_pub_.publish(twist); 
    ros::spinOnce();
    loop_rate.sleep();
    return;
}

void TeleopTurtle::baseLoop(){

  ros::Rate loop_rate(10);
  linear_=angular_=0;
  tcgetattr(kfd, &cooked);
  memcpy(&raw, &cooked, sizeof(struct termios));
  raw.c_lflag &=~ (ICANON | ECHO);

  geometry_msgs::Twist twist;
    linear_ = 1.0;
    twist.angular.z = a_scale_*angular_;
    twist.linear.x = l_scale_*linear_;
    twist_pub_.publish(twist);
    ros::spinOnce();
    loop_rate.sleep(); 
    //std::this_thread::sleep_for(std::chrono::milliseconds(10));
    angular_ = 2.0;
    linear_ = 3.0;
    twist.angular.z = a_scale_*angular_;
    twist.linear.x = l_scale_*linear_;
    twist_pub_.publish(twist); 
    ros::spinOnce();
    loop_rate.sleep();
    return;
}

/*
void TeleopTurtle::keyLoop()
{
  char c;
  bool dirty=false;


  // get the console in raw mode                                                              
  tcgetattr(kfd, &cooked);
  memcpy(&raw, &cooked, sizeof(struct termios));
  raw.c_lflag &=~ (ICANON | ECHO);
  // Setting a new line, then end of file                         
  raw.c_cc[VEOL] = 1;
  raw.c_cc[VEOF] = 2;
  tcsetattr(kfd, TCSANOW, &raw);

  puts("Reading from keyboard");


  for(;;)
  {
    // get the next event from the keyboard  
    if(read(kfd, &c, 1) < 0)
    {
      perror("read():");
      exit(-1);
    }

    linear_=angular_=0;
    ROS_DEBUG("value: 0x%02X\n", c);
  
    switch(c)
    {
      case KEYCODE_L:
        ROS_DEBUG("LEFT");
        angular_ = 1.0;
        dirty = true;
        break;

        //Old code below
      case KEYCODE_R:
        ROS_DEBUG("RIGHT");
        angular_ = -1.0;
        dirty = true;
        break;
      case KEYCODE_U:
        ROS_DEBUG("UP");
        linear_ = 1.0;
        dirty = true;
        break;
      case KEYCODE_D:
        ROS_DEBUG("DOWN");
        linear_ = -1.0;
        dirty = true;
        break;
    }
   

    geometry_msgs::Twist twist;
    twist.angular.z = a_scale_*angular_;
    twist.linear.x = l_scale_*linear_;
    if(dirty ==true)
    {
      twist_pub_.publish(twist);    
      dirty=false;
    }
  }


  return;
}
*/