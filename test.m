
% Use four Gaussian clouds in 10 dimensions.
x = [randn(100,10); randn(50,10)+2; randn(50,10)-5; randn(50,10)+5];

% Estimate epsilon
ep = estimate_epsilon_singer(x);

% Calculate the 3D embedding of this dataset.
[V,l] = diffusion_map(x, ep);
m = map_coordinates(V,l);

disp([ 'Epsilon: ' num2str(ep) ])

% Show the nice picture.
figure;
hold on;
grid on;
plot3(m(:,1),m(:,2),m(:,3),'b*')
title('Diffusion mapped data points')
xlabel('2nd eigenvector')
ylabel('3rd eigenvector')
zlabel('4th eigenvector')
view(45,45)

figure;
hold on;
grid on;
plot(m(:,1),m(:,2),'b*')
title('Diffusion mapped data points')
xlabel('2nd eigenvector')
ylabel('3rd eigenvector')

