clear all,close all

%declaring variables
m=100; %number of nodes
t=1000; %number of slots


lambda=1/exp(1); %overall arrival rate
qr=0.01; %retransmission prob.

% qr=input('enter the qr'); 
% lambda=input('enter the lambda vallue');
qa = 1 - exp(-lambda/m); %new arrival prob.

%qa=0.6;
%counter

success_counter=0;
collision_counter=0; %%number of total collision
attempts_counter=0;


% plot vs slots
packet_entering=zeros(size(1:t)); %to plot packet entering vs slot
packet_leaving=zeros(size(1:t)); %to plot packet leaving vs slot
backlog=zeros(size(1:t)); %%to plot backlog vs slot

%node states
node_state=zeros(size(1:m)); %at initial all nodes are idle

%0--idle node
%1--unbacklogged node ready to transmit(tx)
%2--backlogged node ready to retransmit(retx)
%3--backlogged node waiting for retx

cs=1; %currentslot

while cs<=t 
    
    
    for current_node=1:m %%looking all nodes for each slot if there is tx or retx or new arrival
        if(node_state(current_node)==0 && rand(1)<=qa) %%if node is idle and there is new arrival
            node_state(current_node)=1; %set node_state to ready tx from idle.
            packet_entering(cs)=packet_entering(cs)+1; %%there is new arrival.  
        elseif(node_state(current_node)==3 && rand(1)<=qr)%%if node is backlogged and waiting for retx and there is retx
            node_state(current_node)=2; %%set node_state to ready to retx from waiting for retx
        end
    end
    
    tx=find(node_state==1);%finding node which are ready to tx
    retx=find(node_state==2);%finding node which are ready to retx
    
    current_attempts=length(tx)+length(retx);
    attempts_counter=attempts_counter+current_attempts;
    
   if current_attempts==1 %%only one packet tx/retx 
       success_counter=success_counter+1; %successfull trasnmit
       packet_leaving(cs)=packet_leaving(cs)+1;
       if length(tx)==1 %%there is no retx and one tx
           node_state(tx)=0;%set node state to idle
           backlog(cs+1)=backlog(cs);
       else
           node_state(retx)=0;%set node state to idle from backlogged
           backlog(cs+1)=backlog(cs)-1;
       end
   elseif current_attempts>1 %there is collision
       collision_counter=collision_counter+1;
       backlog(cs+1)=backlog(cs)+length(tx); %all new arrivals become backlogged
       node_state(tx)=3; %set node to waiting for retx
      node_state(retx)=3;
   else%there is no transmission
       backlog(cs+1)=backlog(cs);
   end
           
    packet_entering(cs+1)=packet_entering(cs); %otherwise it will start from zero
    packet_leaving(cs+1)=packet_leaving(cs); 
   
    
    cs=cs+1;
end

%Question 4
%results from simulation
traffic=attempts_counter/t;
freq_success=success_counter/t;
collision_prob=collision_counter/t;

%steady-state prob. of the markov chain
counts=histcounts(backlog);
steadystate_probs=counts/sum(counts);

G = (m*ones(1,m)-(1:m))*qa+(1:m)*qr; % attempt rate
Ps = G.*exp(-G); % probability of success

% avarage prob of success
steadystate_probs = [steadystate_probs, zeros(1,m-length(steadystate_probs))];
avg_prob_success = sum(steadystate_probs.*Ps);


% comparing values
fprintf('\nFrequency of success: %d\n',freq_success);
fprintf('Average probability of success: %d\n',avg_prob_success);
fprintf('relative error of success: %d\n',abs(avg_prob_success-freq_success)/freq_success);

%plot number of backloged nodes vs slot
figure(1)
plot(0:t,backlog);
xlabel('slots')
ylabel('number of backloged nodes')
title('backlogged nodes vs slot')

%plot number of leaving/entering packets
figure(2)
plot(0:t,packet_entering)
hold on
plot(0:t,packet_leaving)
hold off
xlabel('slot number')
ylabel('number of leaving/entering packets')
legend('number of entering','number of leaving')
legend('location','northwest')

%plot histogram of backlogg
figure(3)
histo=histogram(backlog);
xlabel('number of backlogged nodes');
ylabel('counts')
title('histogram of the backlogged nodes')
