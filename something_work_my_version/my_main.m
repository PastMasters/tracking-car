clear
disp('Program started');
vrep = remApi('remoteApi');
vrep.simxFinish(-1);
clientID = vrep.simxStart('127.0.0.1', 19999, true, true, 5000, 5);
if (clientID > -1)
    disp('Connected to remote API server');
    vrep.simxSynchronous(clientID, true);
    % simx_opmode_oneshot��ʾ�Ұ����ݷ���ȥ֮��Ϳ�ʼִ�к������䣬�����㷢����û
    vrep.simxStartSimulation(clientID, vrep.simx_opmode_oneshot);

    % simx_opmode_blocking ȷ����仰ִ�����˲Ż�ִ����һ��
    [~, handle] = vrep.simxGetObjectHandle (clientID, 'Vision_sensor', vrep.simx_opmode_blocking);
    [~, left_handle] = vrep.simxGetObjectHandle (clientID, 'Pioneer_p3dx_leftMotor', vrep.simx_opmode_blocking);
    [~, right_handle] = vrep.simxGetObjectHandle (clientID, 'Pioneer_p3dx_rightMotor', vrep.simx_opmode_blocking);
    
    t = clock;
    currentTime = t(5) * 60 + t(6);
    startTime = t(5) * 60 + t(6);
    out = 0;
    v_max = 3;
    direction = 0;
    while (currentTime - startTime < 30000)   
        % arr ��ͼ��ķֱ��ʣ��൱��ͼ��Ĵ�С��
        [~, size, image] = vrep.simxGetVisionSensorImage2(clientID, handle, 1, vrep.simx_opmode_oneshot); 
        if isempty(image)
           continue 
        end
        [out, size_y] = image_process(image);
        % �����out�Ǽ��ٶȣ������ٶȣ�֮��Ķ�����
        % out = dir_cmd(a_out, size_y);
        %vrep.simxPauseCommunication(clientID, 1);
        if(out > v_max)
            out = v_max;
        end
        if(out < -v_max)
            out = -v_max;
        end
        v1 = v_max + out;
        v2 = v_max - out;
        vrep.simxSetJointTargetVelocity(clientID, left_handle, v1, vrep.simx_opmode_oneshot);
        vrep.simxSetJointTargetVelocity(clientID, right_handle, v2, vrep.simx_opmode_oneshot);
        vrep.simxPauseCommunication(clientID, 0);
        currentTime = currentTime + 10;
        vrep.simxSynchronousTrigger(clientID);
    end
    vrep.simxStopSimulation(clientID,vrep.simx_opmode_blocking); 
    vrep.simxFinish(clientID);
else
    disp('Failed connecting to remote API server');
end
vrep.delete();
disp('Program ended');