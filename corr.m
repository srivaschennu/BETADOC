brain = plottrend('frontiers','ftdwpli',{'participation coefficient'},3,'patient','p10','ylim',[-20 90],'ylabel','\Delta \sigma(\alpha Part. Coef.) (%)','relative','ratio');
plottrend('frontiers','ftdwpli',{'participation coefficient'},3,'patient','p21','ylim',[-20 90],'ylabel','\Delta \sigma(\alpha Part. Coef.) (%)','relative','ratio');
brain = cat(1,brain,ans);

plottrend('frontiers','ftdwpli',{'power'},1,'patient','p03','ylim',[-40 20],'ylabel','\Delta (Norm. \delta Power) (%)','relative','ratio');
brain = cat(1,brain,ans*-1);
plottrend('frontiers','ftdwpli',{'power'},1,'patient','p18','ylim',[-40 20],'ylabel','\Delta (Norm. \delta Power) (%)','relative','ratio');
brain = cat(1,brain,ans*-1);
plottrend('frontiers','ftdwpli',{'participation coefficient'},1,'patient','p28','ylim',[-70 30],'ylabel','\Delta \sigma(\delta Part. Coef.) (%)','relative','ratio');
brain = cat(1,brain,ans*-1);

behav = plottrend('betadoc','ftdwpli',{'crs','auditory','visual','motor','verbal','communication','arousal'},3,'patient','p10','ylim',[-3 4],'ylabel','CRS-R Score');
behav = (behav - behav(1))/23;
plottrend('betadoc','ftdwpli',{'crs','auditory','visual','motor','verbal','communication','arousal'},3,'patient','p21','ylim',[0 9],'ylabel','CRS-R Score');
ans = (ans - ans(1))/23;
behav = cat(1,behav,ans);
plottrend('betadoc','ftdwpli',{'crs','auditory','visual','motor','verbal','communication','arousal'},3,'patient','p03','ylim',[0 9],'ylabel','CRS-R Score')
ans = (ans - ans(1))/23;
behav = cat(1,behav,ans);
plottrend('betadoc','ftdwpli',{'crs','auditory','visual','motor','verbal','communication','arousal'},3,'patient','p18','ylim',[0 9],'ylabel','CRS-R Score')
ans = (ans - ans(1))/23;
behav = cat(1,behav,ans);
plottrend('betadoc','ftdwpli',{'crs','auditory','visual','motor','verbal','communication','arousal'},3,'patient','p28','ylim',[0 9],'ylabel','CRS-R Score')
ans = (ans - ans(1))/23;
behav = cat(1,behav,ans);