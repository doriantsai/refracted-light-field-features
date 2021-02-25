package rv_msgs;

public interface GraspObjectGoal extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GraspObjectGoal";
  static final java.lang.String _DEFINITION = "# Goal definition\nrv_msgs/Observation observation\nint32 index # index of the item in rv_msgs/Observation/detections to grasp\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = true;
  rv_msgs.Observation getObservation();
  void setObservation(rv_msgs.Observation value);
  int getIndex();
  void setIndex(int value);
}
