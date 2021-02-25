package rv_msgs;

public interface ActuateGripperGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ActuateGripperGoal";
  static final java.lang.String _DEFINITION = "# Goal definition\nint8 MODE_STATIC=0\nint8 MODE_GRASP=1\n\nint8 STATE_CLOSED=0\nint8 STATE_OPEN=1\n\n## Grasp control mode\nint8 mode\n\n## Grasp control mode inputs\nint8 state\nfloat64 width\n\n## Grasp parameters\nfloat64 force\nfloat64 speed\n\n## Tolerance\nfloat64 e_inner\nfloat64 e_outer\n\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  static final byte MODE_STATIC = 0;
  static final byte MODE_GRASP = 1;
  static final byte STATE_CLOSED = 0;
  static final byte STATE_OPEN = 1;
  byte getMode();
  void setMode(byte value);
  byte getState();
  void setState(byte value);
  double getWidth();
  void setWidth(double value);
  double getForce();
  void setForce(double value);
  double getSpeed();
  void setSpeed(double value);
  double getEInner();
  void setEInner(double value);
  double getEOuter();
  void setEOuter(double value);
}
