package rv_msgs;

public interface GetRelativePoseRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetRelativePoseRequest";
  static final java.lang.String _DEFINITION = "# Gets the pose of target, in the reference frame\nstring frame_target\nstring frame_reference\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getFrameTarget();
  void setFrameTarget(java.lang.String value);
  java.lang.String getFrameReference();
  void setFrameReference(java.lang.String value);
}
