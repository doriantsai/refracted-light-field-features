package rv_msgs;

public interface AskQuestion$Action extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/AskQuestion$Action";
  static final java.lang.String _DEFINITION = "# Goal definition\nstring ask_text\n---\n\n# Result definition\nstring response_text\n---\n\n# Feedback\nuint8 STATUS_SPEAKING=0\nuint8 STATUS_LISTENING=1\nuint8 STATUS_PROCESSING=2\nuint8 status\n\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
}
