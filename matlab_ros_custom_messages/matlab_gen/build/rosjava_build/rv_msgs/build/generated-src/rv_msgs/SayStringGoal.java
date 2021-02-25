package rv_msgs;

public interface SayStringGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SayStringGoal";
  static final java.lang.String _DEFINITION = "# Goal definition\nstring output_text\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  java.lang.String getOutputText();
  void setOutputText(java.lang.String value);
}
