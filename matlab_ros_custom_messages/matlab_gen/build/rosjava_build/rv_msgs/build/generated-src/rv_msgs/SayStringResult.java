package rv_msgs;

public interface SayStringResult extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SayStringResult";
  static final java.lang.String _DEFINITION = "\n# Result definition\nbool succeeded\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  boolean getSucceeded();
  void setSucceeded(boolean value);
}
