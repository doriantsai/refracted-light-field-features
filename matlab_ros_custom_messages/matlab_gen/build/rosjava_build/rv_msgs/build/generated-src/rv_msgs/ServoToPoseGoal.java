package rv_msgs;

public interface ServoToPoseGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ServoToPoseGoal";
  static final java.lang.String _DEFINITION = "geometry_msgs/PoseStamped stamped_pose\nfloat32 scaling\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  geometry_msgs.PoseStamped getStampedPose();
  void setStampedPose(geometry_msgs.PoseStamped value);
  float getScaling();
  void setScaling(float value);
}
