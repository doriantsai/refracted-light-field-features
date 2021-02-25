package rv_msgs;

public interface SetTaskNameRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/SetTaskNameRequest";
  static final java.lang.String _DEFINITION = "# Request\nstring new_task_name\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getNewTaskName();
  void setNewTaskName(java.lang.String value);
}
