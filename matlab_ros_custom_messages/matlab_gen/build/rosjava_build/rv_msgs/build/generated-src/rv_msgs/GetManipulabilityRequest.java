package rv_msgs;

public interface GetManipulabilityRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetManipulabilityRequest";
  static final java.lang.String _DEFINITION = "geometry_msgs/PoseStamped stamped_pose\nfloat64[] joints\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  geometry_msgs.PoseStamped getStampedPose();
  void setStampedPose(geometry_msgs.PoseStamped value);
  double[] getJoints();
  void setJoints(double[] value);
}
