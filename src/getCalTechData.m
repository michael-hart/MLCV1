function [ desc_tr, desc_sel, desc_te, train_index_output, test_index_output ] = getCalTechData( )
%GETCALTECHDATA Same as getData('Caltech'), except with addtional inputs
%   For easier calling. Generates training and testing data

    % Show training & testing images and their image feature vector (histogram representation)
    showImg = 0; 


    PHOW_Sizes = [4 8 10]; % Multi-resolution, these values determine the scale of each layer.
    PHOW_Step = 8; % The lower the denser. Select from {2,4,8,16}


    close all;
    imgSel = [15 15]; % randomly select 15 images each class without replacement. (For both training & testing)
    % To track the indices used
    train_index_output = zeros(10, imgSel(1));
    test_index_output = zeros(10, imgSel(2));
    folderName = '../rf2017/Caltech_101/101_ObjectCategories';
    classList = dir(folderName);
    classList = {classList(4:end).name}; % 10 classes
    disp(classList);

    disp('Loading training images...')
    % Load Images -> Description (Dense SIFT)
    cnt = 1;
    
    if showImg
        figure('Units','normalized','Position',[.05 .1 .4 .9]);
        suptitle('Training image samples');
    end
    
    % Cycle through training images
    for c = 1:length(classList)
        subFolderName = fullfile(folderName,classList{c});
        imgList = dir(fullfile(subFolderName,'*.jpg'));
        imgIdx{c} = randperm(length(imgList));
        imgIdx_tr = imgIdx{c}(1:imgSel(1));
        train_index_output(c, :) = imgIdx_tr;
        for i = 1:length(imgIdx_tr)
            I = imread(fullfile(subFolderName,imgList(imgIdx_tr(i)).name));

            % Visualise
            if i < 6 & showImg
                subaxis(length(classList),5,cnt,'SpacingVert',0,'MR',0);
                imshow(I);
                cnt = cnt+1;
                drawnow;
            end

            if size(I,3) == 3
                I = rgb2gray(I); % PHOW work on gray scale image
            end

            % For details of image description, see http://www.vlfeat.org/matlab/vl_phow.html
            %  Extracts PHOW features (multi-scaled Dense SIFT)
            [~, desc_tr{c,i}] = vl_phow(single(I),'Sizes',PHOW_Sizes,'Step',PHOW_Step);
        end
    end


    disp('Building visual codebook...')
    % Build visual vocabulary (codebook) for 'Bag-of-Words method'
    desc_sel = single(vl_colsubset(cat(2,desc_tr{:}), 10e4)); % Randomly select 100k SIFT descriptors for clustering

    if showImg
        figure('Units','normalized','Position',[.05 .1 .4 .9]);
        suptitle('Testing image samples');
    end
    disp('Processing testing images...');
    cnt = 1;
    % Load Images -> Description (Dense SIFT)
    for c = 1:length(classList)
        subFolderName = fullfile(folderName,classList{c});
        imgList = dir(fullfile(subFolderName,'*.jpg'));
        imgIdx_te = imgIdx{c}(imgSel(1)+1:sum(imgSel));
        test_index_output(c, :) = imgIdx_te;

        for i = 1:length(imgIdx_te)
            I = imread(fullfile(subFolderName,imgList(imgIdx_te(i)).name));

            % Visualise
            if i < 6 & showImg
                subaxis(length(classList),5,cnt,'SpacingVert',0,'MR',0);
                imshow(I);
                cnt = cnt+1;
                drawnow;
            end

            if size(I,3) == 3
                I = rgb2gray(I);
            end
            [~, desc_te{c,i}] = vl_phow(single(I),'Sizes',PHOW_Sizes,'Step',PHOW_Step);

        end
    end
    
    if showImg
        suptitle('Testing image samples');
        figure('Units','normalized','Position',[.5 .1 .4 .9]);
        suptitle('Testing image representations: 256-D histograms');
    end

end

