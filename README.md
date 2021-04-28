# Simulation of mobile robot in package delivery

This repository includes simulations of mobile robot working in the warehouse facility or distribution center. The robots are moving around the facility to pick up packages from the loading stations and delivering them to unloading stations for storing or processing as shown in the figure below. It is assumed that the occupancy grid map that represents the free and occupied space is available. However there could be other uncontrolled moving agents working in the same environment and those agents cannot be included in the occupancy map. In this project, the robots working in the open environment are able to avoid both the obstacles represented in the occupancy grid map and the uncontrolled agents. 

Two projects are contained in this repository. The [WarehouseRobotWithObstacle](WarehouseRobotWithObstacle) is the simulation of single robot package delivery. The only uncontrol agent is the static obstacle. The [MultipleWarehouseRobots](MultipleWarehouseRobots) is the simulation of multi-robot package delivery in warehouse. In addition to collision-avoidance module in first model, this model has a central scheduler to arrange task allocation.

## Model Overview

The multi-robot delivery system in this repository is modeled in Simulink with the Stateflow charts and Robotics System Toolbox in matlab. The model is comprised of three parts: central scheduler, robot controller, plant.

In particular, the central scheduler sends the dilivery command to each robot. For example, when a robot has arrived at the assigned loading station and picked up the books, the central scheduler will send the message that asks the robot to visit the specific unloading station for the books. When robot finishes the delivery, it will ask robot to go back to the charging station or pick up other packages depending on the schedule designed in the Stateflow charts.

The robot controller will plan the path based on the delivery commands sent by the central scheduler. Then it computes the velocity commands for robot to follow the planned path. If robot have to avoid the uncontrolled agents, the robot controller should further adjust the velocity command based on the observation of the surrounding environment obtained from the sensors.

The plant module contains differential-drive robot model which simulates the execution of the velocity commands and return the ground-truth poses of the robot.

## Collision Avoidance

In order to deliver the packages successfully, robots have to avoid any obstacle during the motion. We need to deal with three problems: (1) How to plan the collision-free path for robot to pick up package and deliver them to unloading station? (2) How to compute the velocity command such that the robot can follow the planned path? (3) How to avoid the unexpected obstacles that may appear when robot is moving? Three components are used in robot controller module to solve each of the three problems: `mobileRobotPRM` roadmap path planner, `Pure Pursuit` path tracking algorithm and `Vector Field Histogram` (VFH) block.

It is assumed that we have a certain knowledge of the environment in the warehouse so that the occupancy grid map can be computed. The `mobileRobotPRM` function takes the occupancy grid map as the argument and computes a probabilistic roadmap (PRM) based on the free and occupied spaces. The PRM is a network graph of possible path. Given the start and goal location, PRM uses the network of connected nodes to find an obstacle-free path.  

Ideally, robot can reach the goal position by simply following the planned path. However in realistic environment, robot's motion is inherently uncertain. For example, the robot could drift off the path on the uneven road. Therefore it is necessary to use a path tracking algorithm, e.g., pure pursuit. The `pure pursuit` computes the velocity commands for following a path using a set of waypoints and current pose. The algorithm tries to move the robot from its current position to reach some look-ahead point in front of the robot.

With `mobileRobotPRM` and `pure pursuit`, robot is able to work in the environment where the only moving objects are robots. The problem happens when robot are working in the open environment where there are uncontrolled agents. Since those agents are not represented in the occupancy map, they may appear in the planned obstacle-free path for the robots. The `VFH` block is used to deal with this issue. The VFH check if the direction provided by the pure pursuit is obstacle-free based on the range-bearing sensor readings and compute steering direction closest to the target direction if there are obstacles in front of the robots. In particular, VFH computes polar density histogram to identify obstacle location and proximity. These histograms are then converted to binary histogram to indicate valid steering direction for the robot.

For example, the binary occupancy map of an warehouse environment is shown in the figure below. Note that an uncontrolled obstacle located in [35, 30] is not included in the map used to compute the PRM. Given the dilvery command fed by the central schedular, the PRM computes the obstacle-free path to the goal location. The robot follows the planned path based on the velocity commands sent by the pure pursuit controller. When robot is close to the uncontrolled obstacle, VFH adjust the steering direction by the sensor readings.
 
![GitHub](WarehouseRobotWithObstacle/demo/demo.gif)

In addition to the static obstacle, the robot can also avoid the uncontrolled moving obstacle. As shown in the second example below, multiple robots are moving in the same environment and they don't know the position of other robots until the sensors observe them. Besides the static obstacle, each robots should also avoid other robots which are not considered in computing the path by PRM. 

![GitHub](MultipleWarehouseRobots/demo/fullview.gif)

A local view on robot 2.

![GitHub](MultipleWarehouseRobots/demo/view2.gif)
