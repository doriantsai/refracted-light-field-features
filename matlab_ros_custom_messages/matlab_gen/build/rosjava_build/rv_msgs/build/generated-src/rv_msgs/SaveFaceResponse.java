package rv_msgs;

public interface SaveFaceResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SaveFaceResponse";
  static final java.lang.String _DEFINITION = "# Response\nstring person_name";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getPersonName();
  void setPersonName(java.lang.String value);
}
