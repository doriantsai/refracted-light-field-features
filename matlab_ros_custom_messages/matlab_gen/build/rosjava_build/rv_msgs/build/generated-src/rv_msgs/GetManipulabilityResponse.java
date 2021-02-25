package rv_msgs;

public interface GetManipulabilityResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetManipulabilityResponse";
  static final java.lang.String _DEFINITION = "float64 score";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  double getScore();
  void setScore(double value);
}
