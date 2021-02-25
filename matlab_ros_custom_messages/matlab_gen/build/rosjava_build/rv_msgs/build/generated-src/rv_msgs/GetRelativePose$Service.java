package rv_msgs;

public interface GetRelativePose$Service extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetRelativePose$Service";
  static final java.lang.String _DEFINITION = "# Gets the pose of target, in the reference frame\nstring frame_target\nstring frame_reference\n---\ngeometry_msgs/PoseStamped relative_pose\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
}
