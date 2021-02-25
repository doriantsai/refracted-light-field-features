package rv_msgs;

public interface MoveToPoseGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/MoveToPoseGoal";
  static final java.lang.String _DEFINITION = "# Goal definition\ngeometry_msgs/PoseStamped goal_pose\nfloat32 speed\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  geometry_msgs.PoseStamped getGoalPose();
  void setGoalPose(geometry_msgs.PoseStamped value);
  float getSpeed();
  void setSpeed(float value);
}
