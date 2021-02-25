package rv_msgs;

public interface GetHoldingStatus$Service extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetHoldingStatus$Service";
  static final java.lang.String _DEFINITION = "# Request\nfloat32 expected_weight  # Not sure if this makes any sense???\n---\n# Response\nbool is_holding\nfloat32 weight_held\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
}
