#include "ros/ros.h"
#include "geometry_msgs/Twist.h"
//Uncomment for Groovy or lower.....
//#include "turtlesim/Velocity.h"
#include "turtlesim/Pose.h"
#include "std_msgs/String.h"
#include <string>
#include <iostream>
#include <signal.h>
#include <termios.h>
#include <stdio.h>
#include <utility>
#include <vector>
#include <math.h>
using namespace std;

ros::Publisher vel_pub;
turtlesim::Pose turtlesim_pose;
string current_mode;
const double PI = 3.14159265359;

//Declarations for the real_Berg_gradient

std::pair<int,int> source_Location;
double max_Berg;
double d_value; // Sets the gradient steepness
int t_value; //time


//Function Declarations
void initialize_real_Berg_gradient(); //Should initialize the real_Berg_gradient arguments
void mode_Callback(const std_msgs::String::ConstPtr& msg);
void modePrint();
string returnMode(); //returns the current mode of the controller
void move_To_Goal(turtlesim::Pose goal_pose, double dist_error);
void pose_Callback(const turtlesim::Pose::ConstPtr & pose_message);
double getDistance(double x1, double y1, double x2, double y2);
void activateCallbacks();
double real_Berg_gradient(double max, std::pair<int,int> center, int D/*steepness*/, std::pair<float,float> pose,int t /*timeFactor*/);
double checkRBG();

/*Modes*/
void patrol_mode(); // Takes the Robot into a preconceived 4-5 goal destinations.
void return_to_Base();
void Looking_for_Source_Mode();
bool endPatrol = false;


int main(int argc, char **argv){

	ros::init(argc, argv, "Controller");
	ros::NodeHandle n;
	ros::Rate loop_rate(0.5);
	ros::Subscriber mode_subscriber = n.subscribe("/modeSpeak", 10, mode_Callback);//subscribes to modeChooser
	ros::Subscriber loc_subscriber = n.subscribe("/turtle1/pose", 10, pose_Callback);//Subscribes to turtlesim's location
	vel_pub = n.advertise<geometry_msgs::Twist>("/turtle1/cmd_vel", 1000);//Publishes command velocities
	//initialize_real_Berg_gradient(); //Sets up the real_Berg_Gradient
	while(ros::ok){
		activateCallbacks();
		if (current_mode == "P"){
			std::cout<<"should be called\n";
			endPatrol = false;
			patrol_mode();
		} 

		if (current_mode == "F"){
			endPatrol = true;
			std::cout<<"Trace Found\n";
			Looking_for_Source_Mode();
			
		}

		if (current_mode == "R"){
			endPatrol = true;
			std::cout<<"Lost Trace, Recovery_mode initiated\n";
			return_to_Base();
		}

	}

ros::spin();
return 0;
}


void initialize_real_Berg_gradient(){
	std::cout<<"Enter Source's X-coordinate\n";
	cin>>source_Location.first;
	std::cout<<"Enter Source's Y-coordinate\n";
	cin>>source_Location.second;
	std::cout<<"Enter max value\n";
	cin>>max_Berg;
	std::cout<<"Enter D value (steepness)\n";
	cin>>d_value;
	std::cout<<"Enter int t value\n";
	cin>>t_value;

	std::cout<<"Berg Gradient has finished accepting arguments....\n";
	return;
}
//This will get the message 'P' or 'B' and put it in current_Mode
void mode_Callback(const std_msgs::String::ConstPtr& msg){
	// std::cout<<"mode_callback activated\n";
	current_mode = msg->data;
	return;	
}
void pose_Callback(const turtlesim::Pose::ConstPtr & pose_message){
	std::cout<"pose_callback activated\n";
	turtlesim_pose.x = pose_message->x;
	turtlesim_pose.y = pose_message->y;
	turtlesim_pose.theta = pose_message->theta;
}

void move_To_Goal(turtlesim::Pose goal_pose, double dist_error){
	//For Groovy and lower
//	turtlesim/Velocity cmd_vel_msg;
	
	//for higher than Groovy
	geometry_msgs::Twist cmd_vel_msg; //This will be the pose location that we want the turtle to follow.
	ros::Rate loop_rate(10);

	do {
		//linear velocity 
		cmd_vel_msg.linear.x = 1.0*getDistance(turtlesim_pose.x, turtlesim_pose.y, goal_pose.x, goal_pose.y);
		cmd_vel_msg.linear.y = 0;
		cmd_vel_msg.linear.z = 0;
	//angular velocity
		cmd_vel_msg.angular.x = 0;
		cmd_vel_msg.angular.y = 0;
		cmd_vel_msg.angular.z = 4*(atan2(goal_pose.y - turtlesim_pose.y, goal_pose.x - turtlesim_pose.x)-turtlesim_pose.theta);

		vel_pub.publish(cmd_vel_msg);
		ros::spinOnce();
		loop_rate.sleep();	
	} while(getDistance(turtlesim_pose.x, turtlesim_pose.y, goal_pose.x, goal_pose.y)>dist_error);
	cout<<"reached End Goal\n";
	cmd_vel_msg.linear.x = 0;
	cmd_vel_msg.angular.z = 0;
	vel_pub.publish(cmd_vel_msg);
	ros::spinOnce();
	//loop_rate.sleep();
}

void activateCallbacks(){
	ros::Rate loop_rate(10);
	ros::spinOnce();
	loop_rate.sleep();
}

double getDistance(double x1, double y1, double x2, double y2){
	return sqrt(pow((x2-x1),2) + pow((y2-y1),2));
}
void modePrint(){
	ros::Rate loop_rate(10);
	cout<<"Printing mode: "<<current_mode<<"\n";
	ros::spinOnce();
	loop_rate.sleep();
	return;
}
string returnMode(){
	return current_mode;
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
		std::cout<<"asp = "<<asp<<"\n";
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

void patrol_mode(){
	while (endPatrol == false){
		std::cout<<"should be in patrol mode()\n";
		ros::Rate loop_rate(0.5);
		std::pair<float,float> Loc0 = make_pair(1,1);
		std::pair<float,float> Loc1 = make_pair(10,0);
		std::pair<float,float> Loc2 = make_pair(10,5);
		std::pair<float,float> Loc3 = make_pair(0,5);
		std::pair<float,float> Loc4 = make_pair(0,10);
		std::pair<float,float> Loc5 = make_pair(10,10);
		std::vector<std::pair <float,float> > locVector;
		locVector.push_back(Loc0);
		locVector.push_back(Loc1);
		locVector.push_back(Loc2);
		locVector.push_back(Loc3);
		locVector.push_back(Loc4);
		locVector.push_back(Loc5);
		for (int i = 0; i < locVector.size(); ++i){
			turtlesim::Pose goal_pose;
			goal_pose.x = locVector[i].first;
			goal_pose.y = locVector[i].second;
			goal_pose.theta = 0;
			if (current_mode != "P"){
				std::cout<<"Not Patrol Mode\n";
				std::cout<<"current mode = "<<current_mode<<"\n";
				return;
			}
			std::cout<<"moving to goal\n";
			move_To_Goal(goal_pose, 0.01);
			//checkRBG();
			ros::spinOnce();
			loop_rate.sleep();	
		}
	}
}

void return_to_Base(){
	turtlesim::Pose goal_pose;
	ros::Rate loop_rate(0.5);
	goal_pose.x = 0;
	goal_pose.y = 0;
	goal_pose.theta = 0;
	move_To_Goal(goal_pose, 0.01);
	std::cout<<"at base camp, stand ready to patrol.\n";
	ros::spinOnce();
	loop_rate.sleep();
}

void Looking_for_Source_Mode(){
	
//For Demo
	/*
	std::cout<<"Trace located.....\n";
	turtlesim::Pose goal_pose;
	ros::Rate loop_rate(0.5);
	goal_pose.x = 10;
	goal_pose.y = 10;
	goal_pose.theta = 0;
	move_To_Goal(goal_pose, 0.01);
	*/
//Moth Algorithim
 

}