package rv_msgs;

public interface SetTaskNameResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SetTaskNameResponse";
  static final java.lang.String _DEFINITION = "# Response\nbool success";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  boolean getSuccess();
  void setSuccess(boolean value);
}
