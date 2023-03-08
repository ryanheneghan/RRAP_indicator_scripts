clear

F = load("sR0a_fog_Moore_MIROC5_45.mat"); % Load Reefmod data

nsims = size(F.coral_cover_per_taxa, 1); % nsims
nreefs = size(F.coral_cover_per_taxa, 2); % nreefs
nyrs = size(F.coral_cover_per_taxa, 3); % nyears
ngroups = size(F.coral_cover_per_taxa, 4); % number of coral groups

if ngroups == 12 % if intervention simulation
ntaxa = ngroups/2;
elseif ngroups == 6 % if counterfactual
ntaxa = ngroups;
end

% Get all coral size classes into single array
juv_sizes = 1;
adol_sizes = 2;
adult_sizes = 3:8;
nsizes = length(juv_sizes)+length(adol_sizes)+length(adult_sizes); 

corals(:, :, :, :, juv_sizes) = F.nb_coral_juv;
corals(:, :, :, :, adol_sizes) = F.nb_coral_adol;
corals(:, :, :, :, adult_sizes) = F.nb_coral_adult;

% Get total numbers of each coral, across unenhanced and enhanced groups
coral_numbers = zeros(nsims,nreefs,nyrs,ntaxa,nsizes);

if ngroups == 12 % If intervention
for tax = 1:6 
    coral_numbers(:,:,:,tax,:) = corals(:,:,:,tax, :) + corals(:,:, :, tax + 6, :);
end
elseif ngroups == 6 % If counterfactual
for tax = 1:6 % Get total numbers of each coral, across unenhanced and enhanced groups
    coral_numbers(:,:,:,tax,:) = corals(:,:,:,tax, :);
end
end


%% Estimate shelter volume based on coral group, colony size and cover
X = struct('coral_numbers', coral_numbers,'nsims', nsims, 'nreefs', nreefs, 'nyrs', nyrs', 'ntaxa', ntaxa, 'nsizes', nsizes);
uncert = 0; % this is 1 if you want to include uncertainty in shelter volume parameters, 0 otherwise
 
[sv, svmax] = shelterVolumeFromReefmod(X, uncert);

shelterVolume = sv./svmax; %express as relative value
shelterVolume(shelterVolume > 1) = 1;
shelterVolume(shelterVolume < 0) = 0;

