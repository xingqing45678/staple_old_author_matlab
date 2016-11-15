function qw1_runTracker()
    close all;clear all;clc;
% RUN_TRACKER  is the external function of the tracker - does initialization and calls trackerMain
    start_frame=1;
    sequence='D:\ImageData\vot15_ball1';%����·������
    %% ��ȡ�ļ� params.txt
    params = readParams('params.txt');%��ȡ�ļ�����ʼ������
	%% ������Ƶ��Ϣ
% 	sequence_path = ['../Sequences/',sequence,'/'];
    sequence_path = [sequence,'/'];
    img_path = [sequence_path 'img/'];%����ͼ��·��
    %% ��ȡ�ļ�
    text_files = dir([sequence_path '*_frames.txt']);
    f = fopen([sequence_path text_files(1).name]);
    frames = textscan(f, '%f,%f');
    if exist('start_frame')%�жϱ������ߺ����Ƿ����
        frames{1} = start_frame;
    else
        frames{1} = 1;
    end
    
    fclose(f);
    
    params.bb_VOT = csvread([sequence_path 'groundtruth_rect.txt']);
    region = params.bb_VOT(frames{1},:);%��ȡgroundtruth�ĵ�һ��8������
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % ��ȡ����ͼ��֡
    dir_content = dir([sequence_path 'img/']);
    % skip '.' and '..' from the count
    n_imgs = length(dir_content) - 2;
    img_files = cell(n_imgs, 1);
    for ii = 1:n_imgs
        img_files{ii} = dir_content(ii+2).name;%imag_files�洢����ͼ��֡�ļ���
    end
       
    img_files(1:start_frame-1)=[];

    im = imread([img_path img_files{1}]);%����һ��ͼ�����
    % �ж��Ƿ�Ҷ�ͼ�� ?
    if(size(im,3)==1)
        params.grayscale_sequence = true;
    end

    params.img_files = img_files;%��ͼ��������������params
    params.img_path = img_path;%��ͼ��·������������params

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(numel(region)==8)%����ͼ�����ػ�����Ԫ�ظ���
        % polygon format
        [cx, cy, w, h] = getAxisAlignedBB(region);%����ʵ��������ȡ�����߽����Ϊ��תͼ��
    else
        x = region(1);
        y = region(2);
        w = region(3);
        h = region(4);
        cx = x+w/2;
        cy = y+h/2;
    end

    % init_pos �Ƿ�Χ������ģ�is the centre of the initial bounding box��
    params.init_pos = [cy cx];
    params.target_sz = round([h w]);%���������������������£
    [params, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, params);
	if params.visualization%Ϊ1ʱ��ͼ��0ʱ����ͼ
		params.videoPlayer = vision.VideoPlayer('Position', [100 100 [size(im,2), size(im,1)]+30]);
	end
    % in runTracker we do not output anything
	params.fout = -1;
	% start the actual tracking
	trackerMain(params, im, bg_area, fg_area, area_resize_factor);
    fclose('all');
end
