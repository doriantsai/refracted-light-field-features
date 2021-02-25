package rv_msgs;

public interface GetLocationPoseResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/GetLocationPoseResponse";
  static final java.lang.String _DEFINITION = "# Response\ngeometry_msgs/Pose location_pose";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  geometry_msgs.Pose getLocationPose();
  void setLocationPose(geometry_msgs.Pose value);
}
