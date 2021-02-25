package rv_msgs;

public interface Listen$Action extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/Listen$Action";
  static final java.lang.String _DEFINITION = "# Goal definition\nfloat32 timeout_seconds\nbool wait_for_wake\n---\n\n# Result definition\nstring text_heard\n---\n\n# Feedback\nuint8 STATUS_LISTENING=0\nuint8 STATUS_PROCESSING=1\nuint8 status\n\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
}
