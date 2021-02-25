package rv_msgs;

public interface GraspObject$Action extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GraspObject$Action";
  static final java.lang.String _DEFINITION = "# Goal definition\nrv_msgs/Observation observation\nint32 index # index of the item in rv_msgs/Observation/detections to grasp\n---\n# Result definition\nint8 result\n---\n# Feedback definition\nint8 status\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
}
