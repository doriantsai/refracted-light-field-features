package rv_msgs;

public interface ServoToPoseResult extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ServoToPoseResult";
  static final java.lang.String _DEFINITION = "# Result definition\nint32 result\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  int getResult();
  void setResult(int value);
}
