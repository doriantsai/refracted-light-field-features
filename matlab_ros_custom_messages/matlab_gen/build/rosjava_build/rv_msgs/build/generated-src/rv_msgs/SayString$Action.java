package rv_msgs;

public interface SayString$Action extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SayString$Action";
  static final java.lang.String _DEFINITION = "# Goal definition\nstring output_text\n---\n\n# Result definition\nbool succeeded\n---\n\n# Feedback\nuint8 STATUS_SPEAKING=0\nuint8 STATUS_PROCESSING=1\nuint8 status\n\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
}
