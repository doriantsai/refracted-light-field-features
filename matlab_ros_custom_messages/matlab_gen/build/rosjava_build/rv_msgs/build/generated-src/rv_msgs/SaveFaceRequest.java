package rv_msgs;

public interface SaveFaceRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SaveFaceRequest";
  static final java.lang.String _DEFINITION = "# Request\nrv_msgs/Detection face\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  rv_msgs.Detection getFace();
  void setFace(rv_msgs.Detection value);
}
