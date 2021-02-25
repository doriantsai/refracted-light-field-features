package rv_msgs;

public interface SetCartesianImpedanceResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SetCartesianImpedanceResponse";
  static final java.lang.String _DEFINITION = "bool success\nstring error";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  boolean getSuccess();
  void setSuccess(boolean value);
  java.lang.String getError();
  void setError(java.lang.String value);
}
