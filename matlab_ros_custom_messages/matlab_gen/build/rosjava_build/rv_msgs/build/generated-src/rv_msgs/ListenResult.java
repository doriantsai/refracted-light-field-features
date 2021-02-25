package rv_msgs;

public interface ListenResult extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ListenResult";
  static final java.lang.String _DEFINITION = "\n# Result definition\nstring text_heard\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  java.lang.String getTextHeard();
  void setTextHeard(java.lang.String value);
}
