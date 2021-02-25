package rv_msgs;

public interface MoveToNamedPoseGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/MoveToNamedPoseGoal";
  static final java.lang.String _DEFINITION = "# Goal definition\nstring pose_name\nfloat32 speed\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  java.lang.String getPoseName();
  void setPoseName(java.lang.String value);
  float getSpeed();
  void setSpeed(float value);
}
