function [feature]=FuncHOG(image, opt)
option = struct(...
    'win_size', [],...
    'sbin', 8,...
    'ProcessFunc', @FuncHOG, ...
    'unique_tag', 'hog',...
    'tag', ''...
    );
feature=features_hog(double(image), option.sbin);
feature = feature(:)';
end