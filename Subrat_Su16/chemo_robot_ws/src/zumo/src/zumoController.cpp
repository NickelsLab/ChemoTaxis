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
// ros::Publisher vel_pub; //Come back to and remove line....
// ros::Publisher vel_pub_sim;		//turtlesim
ros::Publisher vel_pub_actual; //zumo

// turtlesim::Pose turtlesim_pose;//turtlesim
turtlesim::Pose zumo_pose; //zumo

string current_mode;
const double PI = 3.14159265359;

double speedFactor = .05; //Zumo and turtlesim
double angularSpeedFactor = .9; //Ideal is 4 for turtlesim


//Declarations for the real_Berg_gradient

std::pair<int,int> source_Location;
double max_Berg;
double d_value; // Sets the gradient steepness
int t_value; //time


//Function Declarations
// void initialize_real_Berg_gradient(); //Should initialize the real_Berg_gradient arguments
void mode_Callback(const std_msgs::String::ConstPtr& msg);
void modePrint();
string returnMode(); //returns the current mode of the controller
void move_To_Goal(turtlesim::Pose goal_pose, double dist_error);

// void pose_sim_Callback(const turtlesim::Pose::ConstPtr & pose_message); //turtlesim
void pose_actual_Callback(const turtlesim::Pose::ConstPtr & pose_message); //zumo


double getDistance(double x1, double y1, double x2, double y2);
void activateCallbacks();
// double real_Berg_gradient(double max, std::pair<int,int> center, int D/*steepness*/, std::pair<float,float> pose,int t /*timeFactor*/);
// double checkRBG();


/*Modes*/


void patrol_mode(); // Takes the Robot into a preconceived 4-5 goal destinations.
void return_to_Base();
void find_Trace_Mode();


bool patrol_bool = false;
bool recovery_bool = false;
bool found_source_bool = false;
bool return_to_Base_bool = false;


int main(int argc, char **argv){

	ros::init(argc, argv, "Controller");
	ros::NodeHandle n;
	ros::Rate loop_rate(0.5);
	ros::Subscriber mode_subscriber = n.subscribe("/modeSpeak", 10, mode_Callback);//subscribes to modeChooser
	//ros::Subscriber loc_subscriber_sim = n.subscribe("/turtle1/pose", 10, pose_sim_Callback);//Subscribes to turtlesim's location
	ros::Subscriber loc_subscriber_actual = n.subscribe("/zloc", 10, pose_actual_Callback);
	// vel_pub_sim = n.advertise<geometry_msgs::Twist>("/turtle1/cmd_vel", 1000);//Publishes command velocities
	vel_pub_actual = n.advertise<geometry_msgs::Twist>("/cmd_vel", 1000); 
	//initialize_real_Berg_gradient(); //Sets up the real_Berg_Gradient
	while(ros::ok){
		activateCallbacks();
		if (current_mode == "P"){
			std::cout<<"should be called\n";
			patrol_bool = true;
			patrol_mode();
		} 

		if (current_mode == "F"){
			std::cout<<"Found trace should get in recovery mode\n";
		}

		if (current_mode == "R"){
			std::cout<<"I am in Recovery Mode\n";
			return_to_Base();
		}

	}

ros::spin();
return 0;
}


// void initialize_real_Berg_gradient(){
// 	std::cout<<"Enter Source's X-coordinate\n";
// 	cin>>source_Location.first;
// 	std::cout<<"Enter Source's Y-coordinate\n";
// 	cin>>source_Location.second;
// 	std::cout<<"Enter max value\n";
// 	cin>>max_Berg;
// 	std::cout<<"Enter D value (steepness)\n";
// 	cin>>d_value;
// 	std::cout<<"Enter int t value\n";
// 	cin>>t_value;

// 	std::cout<<"Berg Gradient has finished accepting arguments....\n";
// 	return;
// }
//This will get the message 'P' or 'B' and put it in current_Mode
void mode_Callback(const std_msgs::String::ConstPtr& msg){
	// std::cout<<"mode_callback activated\n";
	current_mode = msg->data;
	return;	
}
void pose_sim_Callback(const turtlesim::Pose::ConstPtr & pose_message){
	// std::cout<"pose_sim_callback activated\n";
	// turtlesim_pose.x = pose_message->x;
	// turtlesim_pose.y = pose_message->y;
	// turtlesim_pose.theta = pose_message->theta;
}
void pose_actual_Callback(const turtlesim::Pose::ConstPtr & pose_message){
	//std::cout<<"pose_actual_Callback activated\n";
	zumo_pose.x = pose_message->x;
	zumo_pose.y = pose_message->y;
	zumo_pose.theta = pose_message->theta;
}

void move_To_Goal(turtlesim::Pose goal_pose, double dist_error){
	//For Groovy and lower
	//	turtlesim/Velocity cmd_vel_msg;
	//for higher than Groovy
	geometry_msgs::Twist cmd_vel_msg; //This will be the pose location that we want the turtle to follow.
	ros::Rate loop_rate(10);

	do {
		//linear velocity 
		cmd_vel_msg.linear.x = speedFactor*getDistance(zumo_pose.x, zumo_pose.y, goal_pose.x, goal_pose.y);
		cmd_vel_msg.linear.y = 0;
		cmd_vel_msg.linear.z = 0;
	//angular velocity
		cmd_vel_msg.angular.x = 0;
		cmd_vel_msg.angular.y = 0;
		cmd_vel_msg.angular.z = angularSpeedFactor*(atan2(goal_pose.y - zumo_pose.y, goal_pose.x - zumo_pose.x)-zumo_pose.theta);

		std::cout<<"cmd_vel_msg.linear.x = "<<cmd_vel_msg.linear.x<<"\n";
		std::cout<<"cmd_vel_msg.angular.z = "<<cmd_vel_msg.linear.x<<"\n";

		vel_pub_actual.publish(cmd_vel_msg);
		
		ros::spinOnce();
		//std::cout<<"publish1\n";
		loop_rate.sleep();	
	} while(getDistance(zumo_pose.x, zumo_pose.y, goal_pose.x, goal_pose.y)>dist_error);
	cout<<"reached End Goal\n";
	cmd_vel_msg.linear.x = 0;
	cmd_vel_msg.angular.z = 0;
	vel_pub_actual.publish(cmd_vel_msg);
	ros::spinOnce();
	//std::cout<<"publish2\n";
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
// double real_Berg_gradient(double max, std::pair<int,int> center, int D/*steepness*/,
// 						  std::pair<float,float> pose, int t /*timeFactor*/){
	
// 	double rc_cm = 0.01; //cm
// 		//std::cout<<"rc_cm = "<<rc_cm<<"\n";
// 	double rc = rc_cm*1*pow(10,4); //um
// 		//std::cout<<"rc = "<<rc<<"\n";
// 	double r0 = 0; //a*rc
// 		//std::cout<<"r0 = "<<r0<<"\n";
// 		double first = pow(center.first-pose.first, 2);
// 		double second = pow(center.second-pose.second,2);
// 	double r = pow(first + second, .5);
// 	//(pow((center.first-pose.first),2)+(pow((pow((center.second-pose.second),2)), 0.5)));
// 		//std::cout<<"r = "<<r<<"\n";
// 		//std::cout<<pow(2,2)<<" --> should be 4\n";
// 	double r1 = r-r0;
// 		//std::cout<<"r1 = "<<r1<<"\n";
// 	double t1_num = max*rc*rc;
// 		//std::cout<<"t1_num = "<<t1_num<<"\n";
// 	double t1_den = 2*r1*pow((PI*D*t), 0.5);
// 		//std::cout<<"t1_den = "<<t1_den<<"\n";
// 	double den = 1+(3*rc*r1/(4*D*t)); // unitless
// 		//std::cout<<"den = "<<den<<"\n";
// 	double t_test = exp((-(r1*r1)/(4*D*t))/den);
// 		//std::cout<<"t_test = "<<t_test<<"\n";
// 	double asp = (t1_num/t1_den)*t_test;
// 		std::cout<<"asp = "<<asp<<"\n";
// 	return asp;
// }
// double checkRBG(){
// 	double asp;
// 	std::pair<float, float>tmp;
// 	tmp.first = turtlesim_pose.x;
// 	tmp.second= turtlesim_pose.y;
// 	asp = real_Berg_gradient(max_Berg, source_Location, d_value, tmp,t_value);
// 	/*
// 	min = 0
// 	with 3 significant Digit accuracy -> max = 38966.6
// 	acceptable range is greater than 198542
// 	*/
// 	return asp;	
// }

void patrol_mode(){
	while (patrol_bool == true){
		//std::cout<<"should be in patrol mode()\n";
		ros::Rate loop_rate(0.5);
		//std::pair<float,float> Loc0 = make_pair(5,5);
		std::pair<float,float> Loc1 = make_pair(12,12);
		//std::pair<float,float> Loc2 = make_pair(24,12);
		//std::pair<float,float> Loc3 = make_pair(24,24);
		//std::pair<float,float> Loc4 = make_pair(12,24);
		//std::pair<float,float> Loc5 = make_pair(12,12);
		std::vector<std::pair <float,float> > locVector;
		//locVector.push_back(Loc0);
		locVector.push_back(Loc1);
		//locVector.push_back(Loc2);
		//locVector.push_back(Loc3);
		//locVector.push_back(Loc4);
		//locVector.push_back(Loc5);
		for (int i = 0; i < locVector.size(); ++i){
			turtlesim::Pose goal_pose;
			goal_pose.x = locVector[i].first;
			goal_pose.y = locVector[i].second;
			//goal_pose.theta = 0;
			// if (current_mode != "P"){
			// 	std::cout<<"Not Patrol Mode\n";
			// 	std::cout<<"current mode = "<<current_mode<<"\n";
			// 	return;
			// }
			std::cout<<"moving to goal\n";
			move_To_Goal(goal_pose, 0.5);
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

void find_Trace_Mode(){
	std::cout<<"Trace located.....\n";
}