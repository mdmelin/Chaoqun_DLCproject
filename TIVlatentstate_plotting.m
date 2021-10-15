mousename = 'Fez7';
borders = length(TIV)
[sss, p_value] = corrcoef(pattentive,TIV)

figure;
% plot(Corre_Matrix(:,2));
plot(TIV);
hold on
% ylabel('R Squared / Variance');
ylabel('Variance');
yyaxis right
plot(pattentive);
ylabel('P(attentive state)');
ylim([0 1.0])

title(['Correlation between Variance & P(attentive), ', ...
    mousename, ', Corrcoef: ', num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
% legend({'R Squared', 'Task-Independent Variance', 'Correct Rate'});
xlabel('Trial Number');
legend({'Task-Independent Variance', 'P(attentive state)'});
set(gca,'box','off');
set(gca,'tickdir','out');
hold off