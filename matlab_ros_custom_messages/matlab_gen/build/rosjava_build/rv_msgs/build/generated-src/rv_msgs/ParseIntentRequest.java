package rv_msgs;

public interface ParseIntentRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ParseIntentRequest";
  static final java.lang.String _DEFINITION = "# Request\nstring input_text\nstring intent_type\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getInputText();
  void setInputText(java.lang.String value);
  java.lang.String getIntentType();
  void setIntentType(java.lang.String value);
}
