function newap = bboxpred_rescore(name, testset, year, method)
% Recompute score on testset using bounding box prediction.
%
% name     class name
% testset  test set name
% year     dataset year
% method   regression method

globals;
if exist('year','var') && ~isempty(year)
    VOCyear = year;
else
    year = VOCyear;
end

if exist('testset','var') && ~isempty(testset)
    VOCtest = testset;
else
    testset = VOCtest;
end

if ~exist('method','var')
  method = 'default';
end
pascal_init;

try
    load([cachedir name '_boxes_' VOCopts.testset '_bboxpred_' year]);
catch
    try
        load([cachedir name '_final']);
        if ~isempty(model.bboxpred)
            bboxpred = model.bboxpred;
        end
    catch
        model = bboxpred_train(name, year, method);
        bboxpred = model.bboxpred;
    end
    
    % load test boxes (loads vars: boxes1, parts1)
    load([cachedir name '_boxes_' VOCopts.testset '_' year '_' suffix]);
    
    ids = textread(sprintf(VOCopts.imgsetpath, VOCopts.testset), '%s');
    newboxes = cell(length(parts1),1);
    newparts = cell(length(parts1),1);
    fprintf('%s %s: bbox rescoring %s, total %d\n', procid(), name, testset, length(parts1));
    for i = 1:length(parts1)
        if isempty(parts1{i})
            continue;
        end
        [bbox parts] = bboxpred_get(bboxpred, boxes1{i}, parts1{i});
        if strcmp('inriaperson', name)
            % INRIA uses a mixutre of PNGs and JPGs, so we need to use the annotation
            % to locate the image.  The annotation is not generally available for PASCAL
            % test data (e.g., 2009 test), so this method can fail for PASCAL.
            rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
            im = imread([VOCopts.datadir rec.imgname]);
        else
            im = imread(sprintf(VOCopts.imgpath, ids{i}));
        end
        % clip to image boundary and apply NMS
        [bbox parts] = clipboxes(im, bbox, parts);
        I = nms(bbox, 0.5);
        newboxes{i} = bbox(I,:);
        newparts{i} = parts(I,:);
    end
    
    % save modified boxes
    boxes1 = newboxes;
    parts1 = newparts;
    save([cachedir name '_boxes_' VOCopts.testset '_bboxpred_' year], 'boxes1', 'parts1');
end

% load old ap
% if bEval
%     load([cachedir name '_pr_' VOCopts.testset '_' year '_' suffix]);
% else
%     ap = [];
% end
newap = pascal_eval(name, boxes1, testset, year, ['bboxpred_' method '_' year]);
