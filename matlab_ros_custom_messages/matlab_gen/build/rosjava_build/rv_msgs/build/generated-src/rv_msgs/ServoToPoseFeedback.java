package rv_msgs;

public interface ServoToPoseFeedback extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ServoToPoseFeedback";
  static final java.lang.String _DEFINITION = "# Feedback definition\nfloat64 feedback";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  double getFeedback();
  void setFeedback(double value);
}
