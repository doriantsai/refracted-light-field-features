package rv_msgs;

public interface GetDoorStatusRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetDoorStatusRequest";
  static final java.lang.String _DEFINITION = "# Request\nstring door_name\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getDoorName();
  void setDoorName(java.lang.String value);
}
