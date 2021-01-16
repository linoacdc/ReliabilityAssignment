%Code for AUTh Reliability course assignment by Antonios Favvas and Angelos Vlachos

%Setting up step and time discretization
step=0.001
x=step:step:1.1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculating pdf, cdf and reliability for Case 1(Weibull: Scale=1, Shape=0.2)
pdf1=wblpdf(x,1,0.2);
cdf1=wblcdf(x,1,0.2);
R1 = 1 - cdf1;

%Plotting the results
% figure('Name','Probability density function of Early Failures')
% plot(x,pdf1)
% xlabel('Observation')
% ylabel('Probability Density')
% 
% figure('Name','Cumulative distribution function of Early Failures')
% plot(x,cdf1)
% xlabel('Observation')
% ylabel('Cumulative Probability')
% 
% figure('Name','Reliability of Early Failures')
% plot(x,R1)
% xlabel('Observation')
% ylabel('Reliability')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculating pdf, cdf and reliability for Case 2(Weibull: Scale=4, Shape=1)
pdf2 = wblpdf(x,4,1);
cdf2 = wblcdf(x,4,1);
R2 = 1 - cdf2;

%Plotting the results
% figure('Name','Probability density function of Random Failures')
% plot(x,pdf2)
% xlabel('Observation')
% ylabel('Probability Density')
% ylim([0,0.25])
%
% figure('Name','Cumulative distribution function of Random Failures')
% plot(x,cdf2)
% xlabel('Observation')
% ylabel('Cumulative Probability')
% 
% figure('Name','Reliability of Random Failures')
% plot(x,R2)
% xlabel('Observation')
% ylabel('Reliability')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculating pdf, cdf and reliability for Case 3(Weibull: Scale=1, Shape=5)
pdf3 = wblpdf(x,1,5);
cdf3 = wblcdf(x,1,5);
R3 = 1 - cdf3;

%Plotting the results
% figure('Name','Probability density function of Failures due to aging')
% plot(x,pdf3)
% xlabel('Observation')
% ylabel('Probability Density')
% 
% figure('Name','Cumulative distribution function of Failures due to aging')
% plot(x,cdf3)
% xlabel('Observation')
% ylabel('Cumulative Probability')
% 
% figure('Name','Reliability of Failures due to aging')
% plot(x,R3)
% xlabel('Observation')
% ylabel('Reliability')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generating 1 million random values from the 3 different Weibull distibutions
results1=wblrnd(1,0.2,1000000,1);
results2=wblrnd(4,1,1000000,1);
results3=wblrnd(1,5,1000000,1);

%Plotting these random values as histograms and results should match each pdf 
% figure('Name','Random values from 1st case')
% histogram(results1(results1<=1.1))
% xlabel('Time') 
% ylabel('Number of Values')
% 
% figure('Name','Random values from 2nd case')
% histogram(results2(results2<=1.1))
% xlabel('Time') 
% ylabel('Number of Values')
% 
% figure('Name','Random values from 3rd case')
% histogram(results3(results3<=1.1))
% xlabel('Time') 
% ylabel('Number of Values')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculating the 3 different hazard rates of the 3 different Weibull distributions
hazard1=pdf1./(1-cdf1);
hazard2=pdf2./(1-cdf2);
hazard3=pdf3./(1-cdf3);

%Plotting the 3 hazard rates in the same diagram
% figure('Name','Hazard Rates of the 3 Stages')
% plot(x,hazard1,x,hazard2,x,hazard3)
% xlabel('Time')
% ylabel('Hazard Rate')
% legend('Early Failures','Random Failures','Failures due to aging','location','northwest')

%Calculating the overall hazard rate(?) for 1 component(This must look like a bathtub curve)
lambda = hazard1 + hazard2 + hazard3;

 %Plotting the bathtub curve
%  figure('Name','Overall hazard rate of the system')
%  plot(x,lambda)
%  xlabel('Time')
%  ylabel('Hazard Rate')
%  legend('"Bathtub" Curve','location','northwest')

%Calculating the mean hazard rate of the component 
hazard_mean = mean(lambda)

%Specify the number of experiments to be done 
numberoftests = 10000


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Experiment Phase for 1 component

% initializing the result vector
tests=zeros(numberoftests,1);

%Code in for loop executes once per experiment and creates 1 result
 for i = 1:numberoftests
     %Create a vector that tells us for every point in time whether the
     %component failed or not from the poisson distribution and vector
     %lambda multiplied by the step so each ? refers to each step of time
     %in the 1.1 second period
     y = poissrnd(lambda*step);
     %Find the exact times when the component failed
     timesoffailure = find(y==1);
     %If the vector is empty then the component did not fail so put value 0 in the results vector
     if(isempty(timesoffailure))
         tests(i)=0;
     %Else add the first time the component failed into the results vector(exact time in seconds)
     else
         tests(i)=timesoffailure(1)*step;
     end
 end
 %Now in the tests vector we have the time the component failed for each experiment and the value 0 if it did not fail
 %We now calculate the reliability and the Mean Time To Failure
 reliabilityindeces=find(tests==0);
 Reliability = length(reliabilityindeces)/length(tests)*100
 MTTF = sum(tests((tests~=0)))/length(find(tests~=0))
 hazardRate = 1/MTTF
%Compare results with simple exponential model with mu = 1/hazard_mean
% r = exprnd(1/hazard_mean,1,10000);
% ri=find(r>1.1);
% ReliabilityExp=length(ri)/length(r)*100
% MTTFExp = sum(r((r<=1.1)))/length(find(r<=1.1))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Experiment Phase for system

% initializing the result vector
tests_system=zeros(numberoftests,1);


for i = 1:numberoftests
     %Create a vector for each component that tells us for every point in time whether the
     %component failed or not from the poisson distribution and vector
     %lambda multiplied by the step so each ? refers to each step of time
     %in the 1.1 second period
     y1 = poissrnd(lambda*step);
     y2 = poissrnd(lambda*step);
     %Find the exact times when the components failed
     timesoffailure1 = find(y1==1);
     timesoffailure2 = find(y2==1);
     
     %If the vectors are empty then the system did not fail so put value 0 in the results vector
     if(isempty(timesoffailure1) & isempty(timesoffailure2))
         tests_system(i)=0;
     %Else if only the second component failed the result is the time the time that it failed
     elseif(isempty(timesoffailure1))
              tests_system(i)=timesoffailure2(1)*step;
     %Else if only the second component failed the result is the time the time that it failed
     elseif(isempty(timesoffailure2))
              tests_system(i)=timesoffailure1(1)*step;
     %Else if both have failed the result is the time when the first fault happened out of both components         
     else
              tests_system(i) = min(timesoffailure1(1)*step,timesoffailure2(1)*step);
     end
     
end

%Now in the tests vector we have the time the system failed for each experiment and the value 0 if it did not fail
%We now calculate the reliability and the Mean Time To Failure of the system
reliabilityindecess=find(tests_system==0);
SystemReliability = length(reliabilityindecess)/length(tests_system)*100
SystemMTTF = sum(tests_system((tests_system~=0)))/length(find(tests_system~=0))
SystemHazardRate= 1/SystemMTTF
