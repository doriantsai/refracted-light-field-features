package rv_msgs;

public interface ListenGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ListenGoal";
  static final java.lang.String _DEFINITION = "# Goal definition\nfloat32 timeout_seconds\nbool wait_for_wake\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  float getTimeoutSeconds();
  void setTimeoutSeconds(float value);
  boolean getWaitForWake();
  void setWaitForWake(boolean value);
}
