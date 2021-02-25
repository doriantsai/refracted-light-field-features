package rv_msgs;

public interface MoveToJointPoseGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/MoveToJointPoseGoal";
  static final java.lang.String _DEFINITION = "# Goal definition\nfloat64[] joints\nfloat32 speed\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  double[] getJoints();
  void setJoints(double[] value);
  float getSpeed();
  void setSpeed(float value);
}
