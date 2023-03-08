function [sv, svmax] = shelterVolumeFromReefmod(X, uncert)

if uncert == 0 % If you don't want to include uncertainty in parameter values from Urbina-Barreto 2021
sheltervolume_parameters = ...
    [-8.31, 1.47; ... %branching 
    -8.32, 1.50; ... %tabular 
    -7.37, 1.34; ... %columnar, assumed similar for corymbose Acropora
    -7.37, 1.34; ... %columnar, assumed similar for corymbose non-Acropora
    -9.69, 1.49; ... %massive, assumed similar for encrusting and small massives
    -9.69, 1.49];    %massive,  assumed similar for large massives
end

if uncert == 1
% If you wanted to include uncertainty in relationships, you can use the
% 95% prediction intervals from the paper (calculated by RFH, using data
% available with Urbina-Barretto 2021)

    sheltervolume_parameters = ...
    [-8.31 + normrnd(0,0.514), 1.47; ... %branching
    -8.32 + normrnd(0,0.388), 1.50; ... %tabular
    -7.37 + normrnd(0, 0.561), 1.34; ... %columnar, assumed similar for corymbose Acropora
    -7.37 + normrnd(0, 0.561), 1.34; ... %columnar, assumed similar for corymbose non-Acropora
    -9.69 + normrnd(0, 0.603), 1.49; ... %massive, assumed similar for encrusting and small massives
    -9.69 + normrnd(0, 0.603), 1.49];    %massive,  assumed similar for large massives
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimates shelter volume of coral assemblage from ReefMod output data
% - Ken Anthony AIMS  29 March 2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colony_diameter = [3, 10, 25, 38, 50, 65, 75, 95]; %from ReefMod documentation
colony_area = ((0.5 * colony_diameter).^2) * pi; %colony diameter converted to planar areas (cm2)

% Calculate shelter volume for each taxa and each size class
logcolony_sheltervolume = zeros(X.ntaxa, X.nsizes);

for sp = 1:X.ntaxa
    for size_bin = 1:X.nsizes
        logcolony_sheltervolume(sp, size_bin) = sheltervolume_parameters(sp, 1) + sheltervolume_parameters(sp, 2) * log(colony_area(size_bin)); %shelter volume in dm3
    end
end

% Calculate total shelter volume
shelter_volume = zeros(X.nsims, X.nreefs, X.nyrs, X.ntaxa, X.nsizes);

for sp = 1:X.ntaxa
    for size_bin = 1:X.nsizes
                shelter_volume(:, :, :, sp, size_bin) = (exp(logcolony_sheltervolume(sp, size_bin))) .* X.coral_numbers(:, :, :, sp, size_bin); % shelter volume converted from log and dm to m3
    end
end


%sum over species and size bins and convert to m3
max_large_tables = 400; %assumes 400m2 grid with a 1m diameter table in each
sv = sum(shelter_volume, 4:5);
svmax = (exp(logcolony_sheltervolume(2, 8))).*max_large_tables; 

end


