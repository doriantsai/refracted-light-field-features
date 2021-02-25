package rv_msgs;

public interface Observation extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "rv_msgs/Observation";
  static final java.lang.String _DEFINITION = "# Input image data\nsensor_msgs/CameraInfo depth_info\nsensor_msgs/Image depth_image\nsensor_msgs/CameraInfo rgb_info\nsensor_msgs/Image rgb_image\n\n# List of detections\nrv_msgs/Detection[] detections\n";
  static final boolean _IS_SERVICE = false;
  static final boolean _IS_ACTION = false;
  sensor_msgs.CameraInfo getDepthInfo();
  void setDepthInfo(sensor_msgs.CameraInfo value);
  sensor_msgs.Image getDepthImage();
  void setDepthImage(sensor_msgs.Image value);
  sensor_msgs.CameraInfo getRgbInfo();
  void setRgbInfo(sensor_msgs.CameraInfo value);
  sensor_msgs.Image getRgbImage();
  void setRgbImage(sensor_msgs.Image value);
  java.util.List<rv_msgs.Detection> getDetections();
  void setDetections(java.util.List<rv_msgs.Detection> value);
}
