package rv_msgs;

public interface GetRelativePoseResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetRelativePoseResponse";
  static final java.lang.String _DEFINITION = "geometry_msgs/PoseStamped relative_pose";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  geometry_msgs.PoseStamped getRelativePose();
  void setRelativePose(geometry_msgs.PoseStamped value);
}
