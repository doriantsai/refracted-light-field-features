package rv_msgs;

public interface SetNamedPoseRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SetNamedPoseRequest";
  static final java.lang.String _DEFINITION = "string pose_name\nbool overwrite\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getPoseName();
  void setPoseName(java.lang.String value);
  boolean getOverwrite();
  void setOverwrite(boolean value);
}
