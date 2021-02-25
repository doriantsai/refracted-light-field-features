package rv_msgs;

public interface SetCartesianImpedanceRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SetCartesianImpedanceRequest";
  static final java.lang.String _DEFINITION = "# XYZRPY\nfloat64[6] cartesian_impedance\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  double[] getCartesianImpedance();
  void setCartesianImpedance(double[] value);
}
