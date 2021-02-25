package rv_msgs;

public interface AskQuestionFeedback extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/AskQuestionFeedback";
  static final java.lang.String _DEFINITION = "\n# Feedback\nuint8 STATUS_SPEAKING=0\nuint8 STATUS_LISTENING=1\nuint8 STATUS_PROCESSING=2\nuint8 status";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  static final byte STATUS_SPEAKING = 0;
  static final byte STATUS_LISTENING = 1;
  static final byte STATUS_PROCESSING = 2;
  byte getStatus();
  void setStatus(byte value);
}
