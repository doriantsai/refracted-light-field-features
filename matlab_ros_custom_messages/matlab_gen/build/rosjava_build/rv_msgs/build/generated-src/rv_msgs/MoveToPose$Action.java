package rv_msgs;

public interface MoveToPose$Action extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/MoveToPose$Action";
  static final java.lang.String _DEFINITION = "# Goal definition\ngeometry_msgs/PoseStamped goal_pose\nfloat32 speed\n---\n# Result definition\nint8 result\n---\n# Feedback definition\nint8 status\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
}
