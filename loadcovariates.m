covariatenames = subjlist(1,:);
subjlist = subjlist(2:end,:);

crsdiag = cell2mat(subjlist(:,strcmp('crsdiag',covariatenames)));

% refdiag = cell2mat(subjlist(:,strcmp('refdiag',covariatenames)));
% refaware = double(refdiag > 0);
% refaware(isnan(refdiag)) = NaN;
% 
% crsaware = double(crsdiag > 0);
% petdiag = cell2mat(subjlist(:,strcmp('petdiag',covariatenames)));
% tennis = cell2mat(subjlist(:,strcmp('tennis',covariatenames)));
% etiology = cell2mat(subjlist(:,strcmp('tbi?',covariatenames)));
% age = cell2mat(subjlist(:,strcmp('age',covariatenames)));
% daysonset = cell2mat(subjlist(:,strcmp('daysonset',covariatenames)));
% outcome = double(cell2mat(subjlist(:,strcmp('outcome',covariatenames))) > 2);
% outcome(isnan(cell2mat(subjlist(:,strcmp('outcome',covariatenames))))) = NaN;
% 
% anoxicoutcome = double(cell2mat(subjlist(:,strcmp('outcome',covariatenames))) > 2);
% anoxicoutcome(isnan(cell2mat(subjlist(:,strcmp('outcome',covariatenames))))) = NaN;
% anoxicoutcome(etiology == 1) = NaN;
% tbioutcome = double(cell2mat(subjlist(:,strcmp('outcome',covariatenames))) > 2);
% tbioutcome(isnan(cell2mat(subjlist(:,strcmp('outcome',covariatenames))))) = NaN;
% tbioutcome(etiology == 0) = NaN;
% 
% % SOME ERRORS IN THE CRS-R SCORS
% % crs = cell2mat(subjlist(:,strcmp('crs',covariatenames)));
% 
% auditory = cell2mat(subjlist(:,strcmp('auditory',covariatenames)));
% visual = cell2mat(subjlist(:,strcmp('visual',covariatenames)));
% motor = cell2mat(subjlist(:,strcmp('motor',covariatenames)));
% verbal = cell2mat(subjlist(:,strcmp('verbal',covariatenames)));
% communication = cell2mat(subjlist(:,strcmp('communication',covariatenames)));
% arousal = cell2mat(subjlist(:,strcmp('arousal',covariatenames)));
% 
% crs = auditory + visual + motor + verbal + communication + arousal;
% 
% admvscrs = NaN(size(refdiag));
% admvscrs(refaware == 0) = 0;
% admvscrs(refaware == 0 & crsaware == 0) = 0;
% admvscrs(refaware > 0 & crsaware > 0) = 1;
% admvscrs(refaware == 0 & crsaware > 0) = 2;
% 
% vsoutcome = outcome;
% vsoutcome(crsdiag > 0) = NaN;
% mcsoutcome = outcome;
% mcsoutcome(crsdiag == 0 & crsdiag > 2) = NaN;
% 
% % trajectory = cell2mat(subjlist(:,strcmp('traj',covariates)));