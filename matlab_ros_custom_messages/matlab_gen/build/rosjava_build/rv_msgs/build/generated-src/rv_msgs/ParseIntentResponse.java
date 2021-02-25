package rv_msgs;

public interface ParseIntentResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ParseIntentResponse";
  static final java.lang.String _DEFINITION = "# Response\nstring intent_answer\nstring intent_json";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getIntentAnswer();
  void setIntentAnswer(java.lang.String value);
  java.lang.String getIntentJson();
  void setIntentJson(java.lang.String value);
}
