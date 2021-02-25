package rv_msgs;

public interface ManipulatorState extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/ManipulatorState";
  static final java.lang.String _DEFINITION = "uint16 ESTOP = 1\nuint16 COLLISION = 2\nuint16 JOINT_LIMIT_VIOLATION = 4\nuint16 TORQUE_LIMIT_VIOLATION = 8\nuint16 CARTESIAN_LIMIT_VIOLATION = 16\nuint16 OTHER = 32768\n\ngeometry_msgs/PoseStamped ee_pose\n\nfloat64[] joint_poses\nfloat64[] joint_torques\n\nint32[6] cartesian_collision\nint32[6] cartesian_contact\n\nuint16 errors\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = false;
  static final short ESTOP = 1;
  static final short COLLISION = 2;
  static final short JOINT_LIMIT_VIOLATION = 4;
  static final short TORQUE_LIMIT_VIOLATION = 8;
  static final short CARTESIAN_LIMIT_VIOLATION = 16;
  static final short OTHER = -32768;
  geometry_msgs.PoseStamped getEePose();
  void setEePose(geometry_msgs.PoseStamped value);
  double[] getJointPoses();
  void setJointPoses(double[] value);
  double[] getJointTorques();
  void setJointTorques(double[] value);
  int[] getCartesianCollision();
  void setCartesianCollision(int[] value);
  int[] getCartesianContact();
  void setCartesianContact(int[] value);
  short getErrors();
  void setErrors(short value);
}
