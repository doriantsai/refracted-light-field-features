package rv_msgs;

public interface ProcessObservationResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ProcessObservationResponse";
  static final java.lang.String _DEFINITION = "# Response\nrv_msgs/Observation result";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  rv_msgs.Observation getResult();
  void setResult(rv_msgs.Observation value);
}
