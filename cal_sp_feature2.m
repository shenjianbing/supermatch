function [ sp,K,scores] = cal_sp_feature2( I_rgb,fileName,opts )
% Input:
%     fileName: image name (*.png ...)
% Output:
%     sp: superpixels
%     K: the neighbourhood of sp
%     scores: the similarity scores of sp
%     I_rgb = imread(fileName);
    I_seg = [];
    words = [];
    histograms = [];
    [h, w, ~] = size(I_rgb); % image size
    name = fileName(1:end-4);
    
    
    
        % Calculate the initial segmentation
        t0 = clock;
        [sp, K] = initial_seg(I_rgb, opts, I_seg);
        fprintf('produce superpixels: %f\n',etime(clock,t0));
        %orig_sp = sp; % make a copy of sp. This will be used by the scoring routine.
%         imshow1(I_rgb,sp,h,w);
        %% Features
        t0 = clock;
        if isempty(histograms) % by default, this is true
            % Compute pixel-wise features
            if isempty(words)
                [words, k] = compute_features(I_rgb, I_rgb, 'rgb', opts);
            else % use user 'words'
                k = [];
                for r = 1:length(words)
                    k(r) = max(words{r}(:)); % histogram sizes
                end
            end

            % Compute histograms from features and add them to superpixels
            sp = compute_histograms(sp, words, k, h, w);

        else % use user supplied histograms
            assert(length(histograms) == length(sp)); % one set of histograms for each superpixel
            hist_num = length(histograms{1});
            % Important: You must setup 'opts.features' in spagglom_options.m to
            % match what type of histograms you are supplying, in correct order.

            for r = 1:length(sp) % for each superpixel
                for fn = 1:hist_num % for each histogram
                    sp{r}.hist{fn} = histograms{r}{fn}; % copy the histogram values
                end    
            end
        end
        fprintf('calculate features: %f\n',etime(clock,t0));
         scores = similarity_scores(sp, K, opts);
        
    
%     imshow1(I_rgb,sp,h,w);

end

