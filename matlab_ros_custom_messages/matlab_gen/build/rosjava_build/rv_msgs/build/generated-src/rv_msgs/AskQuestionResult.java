package rv_msgs;

public interface AskQuestionResult extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/AskQuestionResult";
  static final java.lang.String _DEFINITION = "\n# Result definition\nstring response_text\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  java.lang.String getResponseText();
  void setResponseText(java.lang.String value);
}
