package rv_msgs;

public interface Detection extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/Detection";
  static final java.lang.String _DEFINITION = "# Detected class\nstring class_label\n\n# Detection box location\nuint16 x_left\nuint16 y_top\nuint16 width\nuint16 height\n\n# Cropped images capturing the detection (not all are required)\n# NOTE: if these have dimensions other than width x height, your message is wrong\nsensor_msgs/Image cropped_rgb\nsensor_msgs/Image cropped_depth\nsensor_msgs/Image cropped_mask  # Treat this as a white box mask if empty\n\ngeometry_msgs/PoseStamped grasp_pose\nfloat32 grasp_width\nfloat32 grasp_quality";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = false;
  java.lang.String getClassLabel();
  void setClassLabel(java.lang.String value);
  short getXLeft();
  void setXLeft(short value);
  short getYTop();
  void setYTop(short value);
  short getWidth();
  void setWidth(short value);
  short getHeight();
  void setHeight(short value);
  sensor_msgs.Image getCroppedRgb();
  void setCroppedRgb(sensor_msgs.Image value);
  sensor_msgs.Image getCroppedDepth();
  void setCroppedDepth(sensor_msgs.Image value);
  sensor_msgs.Image getCroppedMask();
  void setCroppedMask(sensor_msgs.Image value);
  geometry_msgs.PoseStamped getGraspPose();
  void setGraspPose(geometry_msgs.PoseStamped value);
  float getGraspWidth();
  void setGraspWidth(float value);
  float getGraspQuality();
  void setGraspQuality(float value);
}
