package rv_msgs;

public interface AskQuestionGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/AskQuestionGoal";
  static final java.lang.String _DEFINITION = "# Goal definition\nstring ask_text\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  java.lang.String getAskText();
  void setAskText(java.lang.String value);
}
