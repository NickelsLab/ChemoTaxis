

#include "ros/ros.h"
#include "std_msgs/String.h"
#include "geometry_msgs/Twist.h"
#include "turtlesim/Pose.h"
#include <sstream>
#include <iostream>

turtlesim::Pose turtlesim_pose;
double max_Berg;
double d_value; // Sets the gradient steepness
int t_value; //time
std::string curr_Mode = "P"; // Starts off in Patrol Mode
ros::Publisher chatter_pub;
std::pair<int,int> source_Location;
std_msgs::String msg;
std::stringstream ss;
const double PI = 3.14159265359;
bool send_Patrol_Bool = true;
bool  send_Find_Trace_Bool = false;
bool recovery_Bool = false;
bool restart_Patrol_Bool = false;



void pose_Callback(const turtlesim::Pose::ConstPtr & pose_message);
void send_Patrol_Mode_Command();    //Sends "P"
void send_Find_Trace_Command();     // Sends "F"
void send_Recovery_Mode_Command(); //Sends "R"
void send_Source_Found_Command();  //sends "S"
void send_Return_To_Base_Command(); //Sends "B"

void print_Concentration_Value();


void initialize_real_Berg_gradient();
double checkRBG();
double real_Berg_gradient();
bool checkPose();


int main(int argc, char **argv)
{
  
  ros::init(argc, argv, "talker");
  ros::NodeHandle n;
  chatter_pub = n.advertise<std_msgs::String>("modeSpeak", 1000);
  ros::Subscriber loc_subscriber = n.subscribe("/turtle1/pose", 10, pose_Callback);//Subscribes to turtlesim's location

  ros::Rate loop_rate(10);
  int count = 0;
  initialize_real_Berg_gradient();

  while (ros::ok())
  {
    if (send_Patrol_Bool = true){
      send_Patrol_Mode_Command();
      send_Patrol_Bool = false;
    } 
    ros::spinOnce();
    loop_rate.sleep();

    double tmp = checkRBG();
    print_Concentration_Value(); 
    if (tmp > 700){ // at 10, 10 , 1, 1, 1, 1
      send_Find_Trace_Bool = true;
    }
    while (send_Find_Trace_Bool == true){
      
      send_Find_Trace_Command();
      std::cout<<"trace_Command_Sent\n";
      print_Concentration_Value();
      double tmp2;
      tmp2 = checkRBG();
      if (tmp2 < 500){ //Make 700 for cyclic turtle navigation at 10,10,1,1,1
        //std::cout<<"recovery mode initiated\n";
        recovery_Bool = true;
        std::cout<<"recovery mode initiated\n";
        send_Find_Trace_Bool = false;
      }

    }
    std::cout<<"\n";
    if (recovery_Bool == true){
      send_Recovery_Mode_Command();
      //std::cout<<"recovery mode command sent\n";
      int counter = 0;
      
      //Uncomment to end the delay.....
      ///*
      for (int i = 0; i < 100; ++i){
        loop_rate.sleep();
      }

      //*/



      recovery_Bool = false;
      std::cout<<"should eventually see this!!!!!!!!!!!!!!!!!!!!!!\n";
      //send_Patrol_Bool = true;
      restart_Patrol_Bool = true;
    }



    if (restart_Patrol_Bool == true){
      send_Patrol_Mode_Command();
      send_Patrol_Bool = true;
      restart_Patrol_Bool = false;
      send_Find_Trace_Bool = false;
      recovery_Bool = false;

    }

    
  }

  ros::shutdown();
  return 0;
}

void pose_Callback(const turtlesim::Pose::ConstPtr & pose_message){
  std::cout<"pose_callback activated\n";
  turtlesim_pose.x = pose_message->x;
  turtlesim_pose.y = pose_message->y;
  turtlesim_pose.theta = pose_message->theta;
}

void send_Patrol_Mode_Command(){
    ros::Rate loop_rate(10);
    curr_Mode = "P";
    msg.data = curr_Mode;
    ROS_INFO("%s", msg.data.c_str());
    chatter_pub.publish(msg);
    std::cout<<"Started Patrol\n";

    ros::spinOnce();
    loop_rate.sleep();
    // //++count;
    // std::cout<<"=(Enter 'P'), Return to Base (Enter 'B')\n";
    // std::cout<<"Press 'Q' to Quit\n";
    // std::cin >> curr_Mode;
}

void initialize_real_Berg_gradient(){
  std::cout<<"Enter Source's X-coordinate\n";
  std::cin>>source_Location.first;
  std::cout<<"Enter Source's Y-coordinate\n";
  std::cin>>source_Location.second;
  std::cout<<"Enter max value\n";
  std::cin>>max_Berg;
  std::cout<<"Enter D value (steepness)\n";
  std::cin>>d_value;
  std::cout<<"Enter int t value\n";
  std::cin>>t_value;

  std::cout<<"Berg Gradient has finished accepting arguments....\n";
  return;
}

double real_Berg_gradient(double max, std::pair<int,int> center, int D/*steepness*/,
              std::pair<float,float> pose, int t /*timeFactor*/){
  
  double rc_cm = 0.01; //cm
    //std::cout<<"rc_cm = "<<rc_cm<<"\n";
  double rc = rc_cm*1*pow(10,4); //um
    //std::cout<<"rc = "<<rc<<"\n";
  double r0 = 0; //a*rc
    //std::cout<<"r0 = "<<r0<<"\n";
    double first = pow(center.first-pose.first, 2);
    double second = pow(center.second-pose.second,2);
  double r = pow(first + second, .5);
  //(pow((center.first-pose.first),2)+(pow((pow((center.second-pose.second),2)), 0.5)));
    //std::cout<<"r = "<<r<<"\n";
    //std::cout<<pow(2,2)<<" --> should be 4\n";
  double r1 = r-r0;
    //std::cout<<"r1 = "<<r1<<"\n";
  double t1_num = max*rc*rc;
    //std::cout<<"t1_num = "<<t1_num<<"\n";
  double t1_den = 2*r1*pow((PI*D*t), 0.5);
    //std::cout<<"t1_den = "<<t1_den<<"\n";
  double den = 1+(3*rc*r1/(4*D*t)); // unitless
    //std::cout<<"den = "<<den<<"\n";
  double t_test = exp((-(r1*r1)/(4*D*t))/den);
    //std::cout<<"t_test = "<<t_test<<"\n";
  double asp = (t1_num/t1_den)*t_test;
    //std::cout<<"asp = "<<asp<<"\n";
  return asp;
}

double checkRBG(){
  double asp;
  std::pair<float, float>tmp;
  tmp.first = turtlesim_pose.x;
  tmp.second= turtlesim_pose.y;
  asp = real_Berg_gradient(max_Berg, source_Location, d_value, tmp,t_value);
  /*
  min = 0
  with 3 significant Digit accuracy -> max = 38966.6
  acceptable range is greater than 198542
  */
  return asp; 
}

void print_Concentration_Value(){
  double conc_read;
  conc_read = checkRBG();
  std::cout<<"Concentration Value: "<<conc_read<<"\n";
}
bool checkPose(){
  double conc_read;
  conc_read = checkRBG();
  if (conc_read > 700){
    std::cout<<"source sniffed\n";
    return true;
  } else {
    std::cout<<"source lost\n";
    return false;
  }
}

void send_Find_Trace_Command(){
      ros::Rate loop_rate(10);
      curr_Mode = "F";
      // ss << curr_Mode;
      msg.data = curr_Mode;
      ROS_INFO("%s", msg.data.c_str());
      chatter_pub.publish(msg);
      ros::spinOnce();
      loop_rate.sleep();

}

void send_Recovery_Mode_Command(){
      ros::Rate loop_rate(10);
      curr_Mode = "R";
      // ss << curr_Mode;
      msg.data = curr_Mode;
      ROS_INFO("%s", msg.data.c_str());
      chatter_pub.publish(msg);
      ros::spinOnce();
      loop_rate.sleep();

}