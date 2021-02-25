package rv_msgs;

public interface ActuateGripper$Action extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ActuateGripper$Action";
  static final java.lang.String _DEFINITION = "# Goal definition\nint8 MODE_STATIC=0\nint8 MODE_GRASP=1\n\nint8 STATE_CLOSED=0\nint8 STATE_OPEN=1\n\n## Grasp control mode\nint8 mode\n\n## Grasp control mode inputs\nint8 state\nfloat64 width\n\n## Grasp parameters\nfloat64 force\nfloat64 speed\n\n## Tolerance\nfloat64 e_inner\nfloat64 e_outer\n\n---\n# Result definition\nint32 result\n---\n# Feedback definition\nfloat64 feedback\nfloat64[] data\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
}
