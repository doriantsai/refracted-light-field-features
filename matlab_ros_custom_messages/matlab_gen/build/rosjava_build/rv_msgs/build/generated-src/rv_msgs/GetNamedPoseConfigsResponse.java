package rv_msgs;

public interface GetNamedPoseConfigsResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetNamedPoseConfigsResponse";
  static final java.lang.String _DEFINITION = "string configs";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getConfigs();
  void setConfigs(java.lang.String value);
}
