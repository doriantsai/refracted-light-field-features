package rv_msgs;

public interface Click extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/Click";
  static final java.lang.String _DEFINITION = "int32 x\nint32 y\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = false;
  int getX();
  void setX(int value);
  int getY();
  void setY(int value);
}
