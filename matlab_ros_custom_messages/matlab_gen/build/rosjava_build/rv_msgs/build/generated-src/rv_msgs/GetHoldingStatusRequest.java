package rv_msgs;

public interface GetHoldingStatusRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetHoldingStatusRequest";
  static final java.lang.String _DEFINITION = "# Request\nfloat32 expected_weight  # Not sure if this makes any sense???\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  float getExpectedWeight();
  void setExpectedWeight(float value);
}
