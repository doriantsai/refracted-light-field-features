package rv_msgs;

public interface GetNamesListResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetNamesListResponse";
  static final java.lang.String _DEFINITION = "# Response\nstring[] names_list";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.util.List<java.lang.String> getNamesList();
  void setNamesList(java.util.List<java.lang.String> value);
}
