package rv_msgs;

public interface ProcessObservationRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ProcessObservationRequest";
  static final java.lang.String _DEFINITION = "# Request\nrv_msgs/Observation observation\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  rv_msgs.Observation getObservation();
  void setObservation(rv_msgs.Observation value);
}
