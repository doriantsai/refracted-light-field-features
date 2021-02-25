package rv_msgs;

public interface SimpleRequestResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SimpleRequestResponse";
  static final java.lang.String _DEFINITION = "bool result";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  boolean getResult();
  void setResult(boolean value);
}
