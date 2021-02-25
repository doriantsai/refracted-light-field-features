classdef CustomMsgConsts
    %CustomMsgConsts This class stores all message types
    %   The message types are constant properties, which in turn resolve
    %   to the strings of the actual types.
    
    %   Copyright 2014-2020 The MathWorks, Inc.
    
    properties (Constant)
        rv_msgs_ActuateGripperAction = 'rv_msgs/ActuateGripperAction'
        rv_msgs_ActuateGripperActionFeedback = 'rv_msgs/ActuateGripperActionFeedback'
        rv_msgs_ActuateGripperActionGoal = 'rv_msgs/ActuateGripperActionGoal'
        rv_msgs_ActuateGripperActionResult = 'rv_msgs/ActuateGripperActionResult'
        rv_msgs_ActuateGripperFeedback = 'rv_msgs/ActuateGripperFeedback'
        rv_msgs_ActuateGripperGoal = 'rv_msgs/ActuateGripperGoal'
        rv_msgs_ActuateGripperResult = 'rv_msgs/ActuateGripperResult'
        rv_msgs_AskQuestionAction = 'rv_msgs/AskQuestionAction'
        rv_msgs_AskQuestionActionFeedback = 'rv_msgs/AskQuestionActionFeedback'
        rv_msgs_AskQuestionActionGoal = 'rv_msgs/AskQuestionActionGoal'
        rv_msgs_AskQuestionActionResult = 'rv_msgs/AskQuestionActionResult'
        rv_msgs_AskQuestionFeedback = 'rv_msgs/AskQuestionFeedback'
        rv_msgs_AskQuestionGoal = 'rv_msgs/AskQuestionGoal'
        rv_msgs_AskQuestionResult = 'rv_msgs/AskQuestionResult'
        rv_msgs_Click = 'rv_msgs/Click'
        rv_msgs_Detection = 'rv_msgs/Detection'
        rv_msgs_GetDoorStatus = 'rv_msgs/GetDoorStatus'
        rv_msgs_GetDoorStatusRequest = 'rv_msgs/GetDoorStatusRequest'
        rv_msgs_GetDoorStatusResponse = 'rv_msgs/GetDoorStatusResponse'
        rv_msgs_GetHoldingStatus = 'rv_msgs/GetHoldingStatus'
        rv_msgs_GetHoldingStatusRequest = 'rv_msgs/GetHoldingStatusRequest'
        rv_msgs_GetHoldingStatusResponse = 'rv_msgs/GetHoldingStatusResponse'
        rv_msgs_GetLocationPose = 'rv_msgs/GetLocationPose'
        rv_msgs_GetLocationPoseRequest = 'rv_msgs/GetLocationPoseRequest'
        rv_msgs_GetLocationPoseResponse = 'rv_msgs/GetLocationPoseResponse'
        rv_msgs_GetManipulability = 'rv_msgs/GetManipulability'
        rv_msgs_GetManipulabilityRequest = 'rv_msgs/GetManipulabilityRequest'
        rv_msgs_GetManipulabilityResponse = 'rv_msgs/GetManipulabilityResponse'
        rv_msgs_GetNamedPoseConfigs = 'rv_msgs/GetNamedPoseConfigs'
        rv_msgs_GetNamedPoseConfigsRequest = 'rv_msgs/GetNamedPoseConfigsRequest'
        rv_msgs_GetNamedPoseConfigsResponse = 'rv_msgs/GetNamedPoseConfigsResponse'
        rv_msgs_GetNamesList = 'rv_msgs/GetNamesList'
        rv_msgs_GetNamesListRequest = 'rv_msgs/GetNamesListRequest'
        rv_msgs_GetNamesListResponse = 'rv_msgs/GetNamesListResponse'
        rv_msgs_GetRelativePose = 'rv_msgs/GetRelativePose'
        rv_msgs_GetRelativePoseRequest = 'rv_msgs/GetRelativePoseRequest'
        rv_msgs_GetRelativePoseResponse = 'rv_msgs/GetRelativePoseResponse'
        rv_msgs_GraspObjectAction = 'rv_msgs/GraspObjectAction'
        rv_msgs_GraspObjectActionFeedback = 'rv_msgs/GraspObjectActionFeedback'
        rv_msgs_GraspObjectActionGoal = 'rv_msgs/GraspObjectActionGoal'
        rv_msgs_GraspObjectActionResult = 'rv_msgs/GraspObjectActionResult'
        rv_msgs_GraspObjectFeedback = 'rv_msgs/GraspObjectFeedback'
        rv_msgs_GraspObjectGoal = 'rv_msgs/GraspObjectGoal'
        rv_msgs_GraspObjectResult = 'rv_msgs/GraspObjectResult'
        rv_msgs_JointVelocity = 'rv_msgs/JointVelocity'
        rv_msgs_ListenAction = 'rv_msgs/ListenAction'
        rv_msgs_ListenActionFeedback = 'rv_msgs/ListenActionFeedback'
        rv_msgs_ListenActionGoal = 'rv_msgs/ListenActionGoal'
        rv_msgs_ListenActionResult = 'rv_msgs/ListenActionResult'
        rv_msgs_ListenFeedback = 'rv_msgs/ListenFeedback'
        rv_msgs_ListenGoal = 'rv_msgs/ListenGoal'
        rv_msgs_ListenResult = 'rv_msgs/ListenResult'
        rv_msgs_ManipulatorState = 'rv_msgs/ManipulatorState'
        rv_msgs_MoveToJointPoseAction = 'rv_msgs/MoveToJointPoseAction'
        rv_msgs_MoveToJointPoseActionFeedback = 'rv_msgs/MoveToJointPoseActionFeedback'
        rv_msgs_MoveToJointPoseActionGoal = 'rv_msgs/MoveToJointPoseActionGoal'
        rv_msgs_MoveToJointPoseActionResult = 'rv_msgs/MoveToJointPoseActionResult'
        rv_msgs_MoveToJointPoseFeedback = 'rv_msgs/MoveToJointPoseFeedback'
        rv_msgs_MoveToJointPoseGoal = 'rv_msgs/MoveToJointPoseGoal'
        rv_msgs_MoveToJointPoseResult = 'rv_msgs/MoveToJointPoseResult'
        rv_msgs_MoveToNamedPoseAction = 'rv_msgs/MoveToNamedPoseAction'
        rv_msgs_MoveToNamedPoseActionFeedback = 'rv_msgs/MoveToNamedPoseActionFeedback'
        rv_msgs_MoveToNamedPoseActionGoal = 'rv_msgs/MoveToNamedPoseActionGoal'
        rv_msgs_MoveToNamedPoseActionResult = 'rv_msgs/MoveToNamedPoseActionResult'
        rv_msgs_MoveToNamedPoseFeedback = 'rv_msgs/MoveToNamedPoseFeedback'
        rv_msgs_MoveToNamedPoseGoal = 'rv_msgs/MoveToNamedPoseGoal'
        rv_msgs_MoveToNamedPoseResult = 'rv_msgs/MoveToNamedPoseResult'
        rv_msgs_MoveToPoseAction = 'rv_msgs/MoveToPoseAction'
        rv_msgs_MoveToPoseActionFeedback = 'rv_msgs/MoveToPoseActionFeedback'
        rv_msgs_MoveToPoseActionGoal = 'rv_msgs/MoveToPoseActionGoal'
        rv_msgs_MoveToPoseActionResult = 'rv_msgs/MoveToPoseActionResult'
        rv_msgs_MoveToPoseFeedback = 'rv_msgs/MoveToPoseFeedback'
        rv_msgs_MoveToPoseGoal = 'rv_msgs/MoveToPoseGoal'
        rv_msgs_MoveToPoseResult = 'rv_msgs/MoveToPoseResult'
        rv_msgs_Observation = 'rv_msgs/Observation'
        rv_msgs_ParseIntent = 'rv_msgs/ParseIntent'
        rv_msgs_ParseIntentRequest = 'rv_msgs/ParseIntentRequest'
        rv_msgs_ParseIntentResponse = 'rv_msgs/ParseIntentResponse'
        rv_msgs_ProcessObservation = 'rv_msgs/ProcessObservation'
        rv_msgs_ProcessObservationRequest = 'rv_msgs/ProcessObservationRequest'
        rv_msgs_ProcessObservationResponse = 'rv_msgs/ProcessObservationResponse'
        rv_msgs_SaveFace = 'rv_msgs/SaveFace'
        rv_msgs_SaveFaceRequest = 'rv_msgs/SaveFaceRequest'
        rv_msgs_SaveFaceResponse = 'rv_msgs/SaveFaceResponse'
        rv_msgs_SayStringAction = 'rv_msgs/SayStringAction'
        rv_msgs_SayStringActionFeedback = 'rv_msgs/SayStringActionFeedback'
        rv_msgs_SayStringActionGoal = 'rv_msgs/SayStringActionGoal'
        rv_msgs_SayStringActionResult = 'rv_msgs/SayStringActionResult'
        rv_msgs_SayStringFeedback = 'rv_msgs/SayStringFeedback'
        rv_msgs_SayStringGoal = 'rv_msgs/SayStringGoal'
        rv_msgs_SayStringResult = 'rv_msgs/SayStringResult'
        rv_msgs_ServoToPoseAction = 'rv_msgs/ServoToPoseAction'
        rv_msgs_ServoToPoseActionFeedback = 'rv_msgs/ServoToPoseActionFeedback'
        rv_msgs_ServoToPoseActionGoal = 'rv_msgs/ServoToPoseActionGoal'
        rv_msgs_ServoToPoseActionResult = 'rv_msgs/ServoToPoseActionResult'
        rv_msgs_ServoToPoseFeedback = 'rv_msgs/ServoToPoseFeedback'
        rv_msgs_ServoToPoseGoal = 'rv_msgs/ServoToPoseGoal'
        rv_msgs_ServoToPoseResult = 'rv_msgs/ServoToPoseResult'
        rv_msgs_SetCartesianImpedance = 'rv_msgs/SetCartesianImpedance'
        rv_msgs_SetCartesianImpedanceRequest = 'rv_msgs/SetCartesianImpedanceRequest'
        rv_msgs_SetCartesianImpedanceResponse = 'rv_msgs/SetCartesianImpedanceResponse'
        rv_msgs_SetNamedPoseConfig = 'rv_msgs/SetNamedPoseConfig'
        rv_msgs_SetNamedPoseConfigRequest = 'rv_msgs/SetNamedPoseConfigRequest'
        rv_msgs_SetNamedPoseConfigResponse = 'rv_msgs/SetNamedPoseConfigResponse'
        rv_msgs_SetNamedPose = 'rv_msgs/SetNamedPose'
        rv_msgs_SetNamedPoseRequest = 'rv_msgs/SetNamedPoseRequest'
        rv_msgs_SetNamedPoseResponse = 'rv_msgs/SetNamedPoseResponse'
        rv_msgs_SetPose = 'rv_msgs/SetPose'
        rv_msgs_SetPoseRequest = 'rv_msgs/SetPoseRequest'
        rv_msgs_SetPoseResponse = 'rv_msgs/SetPoseResponse'
        rv_msgs_SetTaskName = 'rv_msgs/SetTaskName'
        rv_msgs_SetTaskNameRequest = 'rv_msgs/SetTaskNameRequest'
        rv_msgs_SetTaskNameResponse = 'rv_msgs/SetTaskNameResponse'
        rv_msgs_SimpleRequest = 'rv_msgs/SimpleRequest'
        rv_msgs_SimpleRequestRequest = 'rv_msgs/SimpleRequestRequest'
        rv_msgs_SimpleRequestResponse = 'rv_msgs/SimpleRequestResponse'
    end
    
    methods (Static, Hidden)
        function messageList = getMessageList
            %getMessageList Generate a cell array with all message types.
            %   The list will be sorted alphabetically.
            
            persistent msgList
            if isempty(msgList)
                msgList = cell(100, 1);
                msgList{1} = 'rv_msgs/ActuateGripperAction';
                msgList{2} = 'rv_msgs/ActuateGripperActionFeedback';
                msgList{3} = 'rv_msgs/ActuateGripperActionGoal';
                msgList{4} = 'rv_msgs/ActuateGripperActionResult';
                msgList{5} = 'rv_msgs/ActuateGripperFeedback';
                msgList{6} = 'rv_msgs/ActuateGripperGoal';
                msgList{7} = 'rv_msgs/ActuateGripperResult';
                msgList{8} = 'rv_msgs/AskQuestionAction';
                msgList{9} = 'rv_msgs/AskQuestionActionFeedback';
                msgList{10} = 'rv_msgs/AskQuestionActionGoal';
                msgList{11} = 'rv_msgs/AskQuestionActionResult';
                msgList{12} = 'rv_msgs/AskQuestionFeedback';
                msgList{13} = 'rv_msgs/AskQuestionGoal';
                msgList{14} = 'rv_msgs/AskQuestionResult';
                msgList{15} = 'rv_msgs/Click';
                msgList{16} = 'rv_msgs/Detection';
                msgList{17} = 'rv_msgs/GetDoorStatusRequest';
                msgList{18} = 'rv_msgs/GetDoorStatusResponse';
                msgList{19} = 'rv_msgs/GetHoldingStatusRequest';
                msgList{20} = 'rv_msgs/GetHoldingStatusResponse';
                msgList{21} = 'rv_msgs/GetLocationPoseRequest';
                msgList{22} = 'rv_msgs/GetLocationPoseResponse';
                msgList{23} = 'rv_msgs/GetManipulabilityRequest';
                msgList{24} = 'rv_msgs/GetManipulabilityResponse';
                msgList{25} = 'rv_msgs/GetNamedPoseConfigsRequest';
                msgList{26} = 'rv_msgs/GetNamedPoseConfigsResponse';
                msgList{27} = 'rv_msgs/GetNamesListRequest';
                msgList{28} = 'rv_msgs/GetNamesListResponse';
                msgList{29} = 'rv_msgs/GetRelativePoseRequest';
                msgList{30} = 'rv_msgs/GetRelativePoseResponse';
                msgList{31} = 'rv_msgs/GraspObjectAction';
                msgList{32} = 'rv_msgs/GraspObjectActionFeedback';
                msgList{33} = 'rv_msgs/GraspObjectActionGoal';
                msgList{34} = 'rv_msgs/GraspObjectActionResult';
                msgList{35} = 'rv_msgs/GraspObjectFeedback';
                msgList{36} = 'rv_msgs/GraspObjectGoal';
                msgList{37} = 'rv_msgs/GraspObjectResult';
                msgList{38} = 'rv_msgs/JointVelocity';
                msgList{39} = 'rv_msgs/ListenAction';
                msgList{40} = 'rv_msgs/ListenActionFeedback';
                msgList{41} = 'rv_msgs/ListenActionGoal';
                msgList{42} = 'rv_msgs/ListenActionResult';
                msgList{43} = 'rv_msgs/ListenFeedback';
                msgList{44} = 'rv_msgs/ListenGoal';
                msgList{45} = 'rv_msgs/ListenResult';
                msgList{46} = 'rv_msgs/ManipulatorState';
                msgList{47} = 'rv_msgs/MoveToJointPoseAction';
                msgList{48} = 'rv_msgs/MoveToJointPoseActionFeedback';
                msgList{49} = 'rv_msgs/MoveToJointPoseActionGoal';
                msgList{50} = 'rv_msgs/MoveToJointPoseActionResult';
                msgList{51} = 'rv_msgs/MoveToJointPoseFeedback';
                msgList{52} = 'rv_msgs/MoveToJointPoseGoal';
                msgList{53} = 'rv_msgs/MoveToJointPoseResult';
                msgList{54} = 'rv_msgs/MoveToNamedPoseAction';
                msgList{55} = 'rv_msgs/MoveToNamedPoseActionFeedback';
                msgList{56} = 'rv_msgs/MoveToNamedPoseActionGoal';
                msgList{57} = 'rv_msgs/MoveToNamedPoseActionResult';
                msgList{58} = 'rv_msgs/MoveToNamedPoseFeedback';
                msgList{59} = 'rv_msgs/MoveToNamedPoseGoal';
                msgList{60} = 'rv_msgs/MoveToNamedPoseResult';
                msgList{61} = 'rv_msgs/MoveToPoseAction';
                msgList{62} = 'rv_msgs/MoveToPoseActionFeedback';
                msgList{63} = 'rv_msgs/MoveToPoseActionGoal';
                msgList{64} = 'rv_msgs/MoveToPoseActionResult';
                msgList{65} = 'rv_msgs/MoveToPoseFeedback';
                msgList{66} = 'rv_msgs/MoveToPoseGoal';
                msgList{67} = 'rv_msgs/MoveToPoseResult';
                msgList{68} = 'rv_msgs/Observation';
                msgList{69} = 'rv_msgs/ParseIntentRequest';
                msgList{70} = 'rv_msgs/ParseIntentResponse';
                msgList{71} = 'rv_msgs/ProcessObservationRequest';
                msgList{72} = 'rv_msgs/ProcessObservationResponse';
                msgList{73} = 'rv_msgs/SaveFaceRequest';
                msgList{74} = 'rv_msgs/SaveFaceResponse';
                msgList{75} = 'rv_msgs/SayStringAction';
                msgList{76} = 'rv_msgs/SayStringActionFeedback';
                msgList{77} = 'rv_msgs/SayStringActionGoal';
                msgList{78} = 'rv_msgs/SayStringActionResult';
                msgList{79} = 'rv_msgs/SayStringFeedback';
                msgList{80} = 'rv_msgs/SayStringGoal';
                msgList{81} = 'rv_msgs/SayStringResult';
                msgList{82} = 'rv_msgs/ServoToPoseAction';
                msgList{83} = 'rv_msgs/ServoToPoseActionFeedback';
                msgList{84} = 'rv_msgs/ServoToPoseActionGoal';
                msgList{85} = 'rv_msgs/ServoToPoseActionResult';
                msgList{86} = 'rv_msgs/ServoToPoseFeedback';
                msgList{87} = 'rv_msgs/ServoToPoseGoal';
                msgList{88} = 'rv_msgs/ServoToPoseResult';
                msgList{89} = 'rv_msgs/SetCartesianImpedanceRequest';
                msgList{90} = 'rv_msgs/SetCartesianImpedanceResponse';
                msgList{91} = 'rv_msgs/SetNamedPoseConfigRequest';
                msgList{92} = 'rv_msgs/SetNamedPoseConfigResponse';
                msgList{93} = 'rv_msgs/SetNamedPoseRequest';
                msgList{94} = 'rv_msgs/SetNamedPoseResponse';
                msgList{95} = 'rv_msgs/SetPoseRequest';
                msgList{96} = 'rv_msgs/SetPoseResponse';
                msgList{97} = 'rv_msgs/SetTaskNameRequest';
                msgList{98} = 'rv_msgs/SetTaskNameResponse';
                msgList{99} = 'rv_msgs/SimpleRequestRequest';
                msgList{100} = 'rv_msgs/SimpleRequestResponse';
            end
            
            messageList = msgList;
        end
        
        function serviceList = getServiceList
            %getServiceList Generate a cell array with all service types.
            %   The list will be sorted alphabetically.
            
            persistent svcList
            if isempty(svcList)
                svcList = cell(16, 1);
                svcList{1} = 'rv_msgs/GetDoorStatus';
                svcList{2} = 'rv_msgs/GetHoldingStatus';
                svcList{3} = 'rv_msgs/GetLocationPose';
                svcList{4} = 'rv_msgs/GetManipulability';
                svcList{5} = 'rv_msgs/GetNamedPoseConfigs';
                svcList{6} = 'rv_msgs/GetNamesList';
                svcList{7} = 'rv_msgs/GetRelativePose';
                svcList{8} = 'rv_msgs/ParseIntent';
                svcList{9} = 'rv_msgs/ProcessObservation';
                svcList{10} = 'rv_msgs/SaveFace';
                svcList{11} = 'rv_msgs/SetCartesianImpedance';
                svcList{12} = 'rv_msgs/SetNamedPoseConfig';
                svcList{13} = 'rv_msgs/SetNamedPose';
                svcList{14} = 'rv_msgs/SetPose';
                svcList{15} = 'rv_msgs/SetTaskName';
                svcList{16} = 'rv_msgs/SimpleRequest';
            end
            
            % The message list was already sorted, so don't need to sort
            % again.
            serviceList = svcList;
        end
        
        function actionList = getActionList
            %getActionList Generate a cell array with all action types.
            %   The list will be sorted alphabetically.
            
            persistent actList
            if isempty(actList)
                actList = cell(9, 1);
                actList{1} = 'rv_msgs/ActuateGripper';
                actList{2} = 'rv_msgs/AskQuestion';
                actList{3} = 'rv_msgs/GraspObject';
                actList{4} = 'rv_msgs/Listen';
                actList{5} = 'rv_msgs/MoveToJointPose';
                actList{6} = 'rv_msgs/MoveToNamedPose';
                actList{7} = 'rv_msgs/MoveToPose';
                actList{8} = 'rv_msgs/SayString';
                actList{9} = 'rv_msgs/ServoToPose';
            end
            
            % The message list was already sorted, so don't need to sort
            % again.
            actionList = actList;
        end
    end
end
