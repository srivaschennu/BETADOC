refdiag = cell2mat(subjlist(:,2));
refaware = double(cell2mat(subjlist(:,2)) > 0);
refaware(isnan(refdiag)) = NaN;
crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);
petdiag = cell2mat(subjlist(:,4));
tennis = cell2mat(subjlist(:,5));
etiology = cell2mat(subjlist(:,6));
age = cell2mat(subjlist(:,7));
daysonset = cell2mat(subjlist(:,9));
outcome = double(cell2mat(subjlist(:,10)) > 2);
outcome(isnan(cell2mat(subjlist(:,10)))) = NaN;

anoxicoutcome = double(cell2mat(subjlist(:,10)) > 2);
anoxicoutcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
anoxicoutcome(etiology == 1) = NaN;
tbioutcome = double(cell2mat(subjlist(:,10)) > 2);
tbioutcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
tbioutcome(etiology == 0) = NaN;
mcstennis = tennis .* crsdiag;
mcstennis(crsdiag == 0) = NaN;
crs = cell2mat(subjlist(:,11));

admvscrs = NaN(size(refdiag));
admvscrs(refaware == 0) = 0;
admvscrs(refaware == 0 & crsaware == 0) = 0;
admvscrs(refaware > 0 & crsaware > 0) = 1;
admvscrs(refaware == 0 & crsaware > 0) = 2;

etiooutcome = NaN(size(crsdiag));
etiooutcome(etiology == 0 & outcome == 0) = 0;
etiooutcome(etiology == 0 & outcome == 1) = 1;
etiooutcome(etiology == 1 & outcome == 0) = 2;
etiooutcome(etiology == 1 & outcome == 1) = 3;

vsoutcome = outcome;
vsoutcome(crsdiag > 0) = NaN;
mcsoutcome = outcome;
mcsoutcome(crsdiag == 0 & crsdiag > 2) = NaN;

trajectory = cell2mat(subjlist(:,17));