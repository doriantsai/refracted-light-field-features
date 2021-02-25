package rv_msgs;

public interface GetDoorStatusResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetDoorStatusResponse";
  static final java.lang.String _DEFINITION = "# Response\nint8 result";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  byte getResult();
  void setResult(byte value);
}
