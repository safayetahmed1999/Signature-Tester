% Define the file paths for the signature images
refFile = 'reference_signature.jpg';
testFile = 'test_signature.jpg';

% Check if the files exist
if ~isfile(refFile)
    error('Error: File "%s" does not exist in the current directory.', refFile);
end

if ~isfile(testFile)
    error('Error: File "%s" does not exist in the current directory.', testFile);
end

% Load the signature images
refSignature = imread(refFile);
testSignature = imread(testFile);

% Convert to grayscale
refGray = rgb2gray(refSignature);
testGray = rgb2gray(testSignature);

% Binarize the images
refBinary = imbinarize(refGray);
testBinary = imbinarize(testGray);

% Resize the images to 256x256
refResized = imresize(refBinary, [256, 256]);
testResized = imresize(testBinary, [256, 256]);

% Detect edges using the Canny method
refEdges = edge(refResized, 'Canny');
testEdges = edge(testResized, 'Canny');

% Extract region properties
refStats = regionprops(refEdges, 'Area', 'Perimeter', 'Centroid');
testStats = regionprops(testEdges, 'Area', 'Perimeter', 'Centroid');

% Ensure at least one region is detected
if isempty(refStats)
    error('Error: No regions detected in the reference signature.');
end
if isempty(testStats)
    error('Error: No regions detected in the test signature.');
end

% Select the largest region in both signatures
[~, idxRef] = max([refStats.Area]);
[~, idxTest] = max([testStats.Area]);
refStats = refStats(idxRef);
testStats = testStats(idxTest);

% Convert binary images to uint8 for SSIM
[ssimValue, ~] = ssim(uint8(refResized) * 255, uint8(testResized) * 255);

% Compute differences in area and perimeter
areaDiff = abs(refStats.Area - testStats.Area);
perimeterDiff = abs(refStats.Perimeter - testStats.Perimeter);

% Set thresholds for matching
ssimThreshold = 0.8;
areaThreshold = 500;
perimeterThreshold = 50;

% Determine if the signatures match
if ssimValue > ssimThreshold && areaDiff < areaThreshold && perimeterDiff < perimeterThreshold
    result = 'Signatures Match';
    color = 'green';
else
    result = 'Signatures Do Not Match';
    color = 'red';
end

% Display the results
figure;
subplot(1, 2, 1);
imshow(refSignature);
title('Reference Signature');
subplot(1, 2, 2);
imshow(testSignature);
title('Test Signature');

sgtitle(result, 'Color', color, 'FontSize', 14);
