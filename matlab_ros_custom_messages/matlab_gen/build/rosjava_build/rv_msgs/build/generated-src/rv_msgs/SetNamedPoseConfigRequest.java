package rv_msgs;

public interface SetNamedPoseConfigRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SetNamedPoseConfigRequest";
  static final java.lang.String _DEFINITION = "string config_path\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getConfigPath();
  void setConfigPath(java.lang.String value);
}
