covariates = subjlist(1,:);
subjlist = subjlist(2:end,:);

refdiag = cell2mat(subjlist(:,strcmp('refdiag',covariates)));
refaware = double(refdiag > 0);
refaware(isnan(refdiag)) = NaN;
crsdiag = cell2mat(subjlist(:,strcmp('crsdiag',covariates)));
crsaware = double(crsdiag > 0);
petdiag = cell2mat(subjlist(:,strcmp('petdiag',covariates)));
tennis = cell2mat(subjlist(:,strcmp('tennis',covariates)));
etiology = cell2mat(subjlist(:,strcmp('tbi?',covariates)));
age = cell2mat(subjlist(:,strcmp('age',covariates)));
daysonset = cell2mat(subjlist(:,strcmp('daysonset',covariates)));
outcome = double(cell2mat(subjlist(:,strcmp('outcome',covariates))) > 2);
outcome(isnan(cell2mat(subjlist(:,strcmp('outcome',covariates))))) = NaN;

anoxicoutcome = double(cell2mat(subjlist(:,strcmp('outcome',covariates))) > 2);
anoxicoutcome(isnan(cell2mat(subjlist(:,strcmp('outcome',covariates))))) = NaN;
anoxicoutcome(etiology == 1) = NaN;
tbioutcome = double(cell2mat(subjlist(:,strcmp('outcome',covariates))) > 2);
tbioutcome(isnan(cell2mat(subjlist(:,strcmp('outcome',covariates))))) = NaN;
tbioutcome(etiology == 0) = NaN;

crs = cell2mat(subjlist(:,strcmp('crs',covariates)));
auditory = cell2mat(subjlist(:,strcmp('auditory',covariates)));
visual = cell2mat(subjlist(:,strcmp('visual',covariates)));
motor = cell2mat(subjlist(:,strcmp('motor',covariates)));
verbal = cell2mat(subjlist(:,strcmp('verbal',covariates)));
communication = cell2mat(subjlist(:,strcmp('communication',covariates)));
arousal = cell2mat(subjlist(:,strcmp('arousal',covariates)));

admvscrs = NaN(size(refdiag));
admvscrs(refaware == 0) = 0;
admvscrs(refaware == 0 & crsaware == 0) = 0;
admvscrs(refaware > 0 & crsaware > 0) = 1;
admvscrs(refaware == 0 & crsaware > 0) = 2;

vsoutcome = outcome;
vsoutcome(crsdiag > 0) = NaN;
mcsoutcome = outcome;
mcsoutcome(crsdiag == 0 & crsdiag > 2) = NaN;

% trajectory = cell2mat(subjlist(:,strcmp('traj',covariates)));