; Auto-generated. Do not edit!


(cl:in-package zumo-msg)


;//! \htmlinclude modeMsg.msg.html

(cl:defclass <modeMsg> (roslisp-msg-protocol:ros-message)
  ((modeType
    :reader modeType
    :initarg :modeType
    :type cl:string
    :initform ""))
)

(cl:defclass modeMsg (<modeMsg>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <modeMsg>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'modeMsg)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name zumo-msg:<modeMsg> is deprecated: use zumo-msg:modeMsg instead.")))

(cl:ensure-generic-function 'modeType-val :lambda-list '(m))
(cl:defmethod modeType-val ((m <modeMsg>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader zumo-msg:modeType-val is deprecated.  Use zumo-msg:modeType instead.")
  (modeType m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <modeMsg>) ostream)
  "Serializes a message object of type '<modeMsg>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'modeType))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'modeType))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <modeMsg>) istream)
  "Deserializes a message object of type '<modeMsg>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'modeType) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'modeType) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<modeMsg>)))
  "Returns string type for a message object of type '<modeMsg>"
  "zumo/modeMsg")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'modeMsg)))
  "Returns string type for a message object of type 'modeMsg"
  "zumo/modeMsg")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<modeMsg>)))
  "Returns md5sum for a message object of type '<modeMsg>"
  "e0cc5967afa4b06a4d62ab745cf0e08b")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'modeMsg)))
  "Returns md5sum for a message object of type 'modeMsg"
  "e0cc5967afa4b06a4d62ab745cf0e08b")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<modeMsg>)))
  "Returns full string definition for message of type '<modeMsg>"
  (cl:format cl:nil "string modeType~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'modeMsg)))
  "Returns full string definition for message of type 'modeMsg"
  (cl:format cl:nil "string modeType~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <modeMsg>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'modeType))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <modeMsg>))
  "Converts a ROS message object to a list"
  (cl:list 'modeMsg
    (cl:cons ':modeType (modeType msg))
))
