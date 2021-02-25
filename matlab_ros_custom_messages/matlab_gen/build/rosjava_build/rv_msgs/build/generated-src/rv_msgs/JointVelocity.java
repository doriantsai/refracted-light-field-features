package rv_msgs;

public interface JointVelocity extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/JointVelocity";
  static final java.lang.String _DEFINITION = "float64[] joints\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = false;
  double[] getJoints();
  void setJoints(double[] value);
}
