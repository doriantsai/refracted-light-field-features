package rv_msgs;

public interface GetHoldingStatusResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetHoldingStatusResponse";
  static final java.lang.String _DEFINITION = "# Response\nbool is_holding\nfloat32 weight_held";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  boolean getIsHolding();
  void setIsHolding(boolean value);
  float getWeightHeld();
  void setWeightHeld(float value);
}
