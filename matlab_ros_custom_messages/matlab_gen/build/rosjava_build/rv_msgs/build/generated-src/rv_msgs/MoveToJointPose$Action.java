package rv_msgs;

public interface MoveToJointPose$Action extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/MoveToJointPose$Action";
  static final java.lang.String _DEFINITION = "# Goal definition\nfloat64[] joints\nfloat32 speed\n---\n# Result definition\nint8 result\n---\n# Feedback definition\nint8 status";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
}
