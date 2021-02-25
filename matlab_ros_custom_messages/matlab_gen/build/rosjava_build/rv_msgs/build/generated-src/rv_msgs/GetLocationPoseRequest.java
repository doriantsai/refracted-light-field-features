package rv_msgs;

public interface GetLocationPoseRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetLocationPoseRequest";
  static final java.lang.String _DEFINITION = "# Request\nstring location_name\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getLocationName();
  void setLocationName(java.lang.String value);
}
