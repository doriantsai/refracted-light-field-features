package rv_msgs;

public interface ActuateGripperFeedback extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ActuateGripperFeedback";
  static final java.lang.String _DEFINITION = "# Feedback definition\nfloat64 feedback\nfloat64[] data";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  double getFeedback();
  void setFeedback(double value);
  double[] getData();
  void setData(double[] value);
}
