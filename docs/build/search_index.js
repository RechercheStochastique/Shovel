var documenterSearchIndex = {"docs":
[{"location":"Stop/#Estimation-for-a-single-qubit","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"","category":"section"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"When a qubit in state alphaket0 + betaket1 is measured, it either returns 0 or 1 with probability p=alpha^2 and 1-p=beta^2 = 1-alpha^2. The objective of a quantum computer program is often to get the value of alpha. So the program is run a large number of time and the relative frequancy of zeros is computed. By the law of large numbers that proportion will converge to alpha^2. The number of time the programs needs to run depends on the desired precision of the estimate. This precision is defined as a interval of confidence. That is, a maximum distance between the real value of alpha and the value of the estimate with a minimum probability. This can be rephrase as: {\\it the estimate does not differ from the real value by more than Delta with a probability greater than 1-gamma}. The parameters Delta and gamma are fixed by the program user and the program is run until the precision is met.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Unfortunately, the number is required iterations is dependant on the unknown value so the user is left to do trial until the result is satisfactory.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"In the following paper we presents a method to sequentially assess is a sufficient number of iterations have been done to meet the precision requirements. The users simply enters the precision parameters Delta and gamma and let the program iterate until it is reached.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"In the first section we present the methods for estimating alpha^2 for one qubit at a time. We then address the case for f(alpha^2). In the next section we address the problem of estimating several qubits at the same time. We then consider the problem of noise in the estimation process.","category":"page"},{"location":"Stop/#Sampling-for-\\alpha2","page":"Estimation for a single qubit","title":"Sampling for alpha^2","text":"","category":"section"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Suppose the qubit is measured N times and let X_1 X_2X_N be the observed values. We have that Pbig( X_n = 0) =  alpha ^2 = p big), hence the following natural estimator of alpha ^2.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Let S_N = X_1++X_N, F_N= N - S_N and","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"hatp = widehat alpha ^2 = fracS_NN","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The variance of this estimator is given by:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Vbig( hatp big) = fracp ( 1- p)N","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"If M is large, then  ","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Z= sqrtfracNp(1-p)(hatp - p )","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"has an approximate normal distribution with mean 0 and variance 1. ","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"If one is interested in getting a estimate of p with a fixed minimal precision, it will usually be in the form of a interval  hatp-Delta hatp+Delta havin a probability 1-gamma of containing the true unknown p. Typically, Delta is defined by the number of significant digits: Delta =2times 10^-k, where k is the number of digits. The confidence level is defined by a small value of gamma such as 5\\%, 1\\% or even less. The smaller the value of gamma the more likely the probability for the interval to include the real, but unknown, value of p.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Using the asymptotic normal distribution of Z in (\\ref{Z.eq}), let Phi()^-1 be the inverse of the normal cumulative distribution function and set","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"z = Phi^-1big( 1- gamma2 big)","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"We seek N such that","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"beginaligned\r\n 1- gamma2 =  Pbigg -z  sqrtfracNp(1-p)(hatp - p )  z bigg  \r\n= Pbigg -z sqrtfracp(1-p)N  (hatp - p )  z sqrtfracp(1-p)N bigg \r\nendaligned","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The length of the interval is therefore given by 2zsqrtp(1-p)N and must be less or equal to 2Delta, hence:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"N = p(1-p) bigg fracPhi^-1big( 1- gamma2 big)Delta bigg^2","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"where the constant Phi^-1big( 1- gamma2 big)  Delta is large given that Phi^-1big( 1- gamma2 big) is larger than 1 and that Delta is usually a small number accounting for the number of correct digits.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The problem with equation (\\ref{simpleN.eq}) is that is relies on the knowledge of p which is precisely what we are trying to find. One option is the take the worst case, which happens when p=12. In this case (\\ref{simpleN.eq}) becomes:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"N = bigg fracPhi^-1big( 1- gamma2 big)2Delta bigg^2","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"As an example, with Delta=00001 and gamma=005, we have N = 95,062,500.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"An alternate solution is to go sequentially and update the target number of trial as we get a better estimate of N.","category":"page"},{"location":"Stop/#Sequential-Estimation","page":"Estimation for a single qubit","title":"Sequential Estimation","text":"","category":"section"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"If we proceed sequentialy, the sample size is increased progressively and, at each step, a decision is taken as to continue or stop.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"I would be tempting to simply reuse equation \\ref{simpleN.eq} with hatp estimated after a few steps to compute N with:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"N = hatp(1-hatp) bigg fracPhi^-1big( 1- gamma2 big)Delta bigg^2 = frac S_NF_NN^2 bigg fracPhi^-1big( 1- gamma2 big)Delta bigg^2","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Setting","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"H(gammaDelta)= bigg( frac Phi^-1big( 1- gamma2 big)Delta bigg)^23","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"we have:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"N=  big( S_NF_N big)^13H(gammaDelta)","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"On average, big( S_NF_N big)^13 increases at rate N^23. Hence, at one point N will become greater and sampling should stop.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"There is one problem however with equation \\ref{eq.seq1}. At the beginning of the process it is very likely to get several zeros in a row without ones (or the reverse). It that case, sqrtS_NF_N is null and the process should stop immediately. This situation is more likely to happen when p is close to either 1 (or 0 for the reverse situation).","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Setting a minimal number of trial before we start comparing N with S_NF_N would be an option. In order to determine such a value we must consider the case where p is very small and remember that is are satisfied with a precision of Delta for our estimate. So any value of p estimated to be 0 while it is in fact smaller than Delta is acceptable. ","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Assume now that p=Delta, so that the probability that X_n=1 is very high. Then the probability of getting a sequence of N ones in a row is given by (1-Delta)^N. We dont want to mae the error of claming the p=0 with a higher probability than 1=gamma. Therefore, N must be large enough so that Delta^N1-gamma. Hence, N  log(1-gamma)log(1-Delta). For p1-Delta the result is the same.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The final stopping rule is therefore: ","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Stop samplig when N ge maxbigg fraclog(1-gamma)log(1-Delta)  big( S_NF_N big)^13H(gammaDelta) bigg","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"With Delta=00001 and gamma=005, we have H(005 00001)=727 so :","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Stop samplig when N ge maxbig 9500  727big( S_NF_N big)^13 big","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Since S_NF_N approx N^2p(1-p), for p=12 at trial 9,500 we have 727(S_NF_N)^13 approx 727 big(9500^24)^13=205430. In the wost case S_N and F_N are very close (approx N2) and the process will go on until N= 727(N^24)^13 which happens when N=727^34= 96060145 which is very close the worst case with a fixed sample size.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"For p=14, S_NF_N approx 3N^216 and the process will lkkely stop for N in th neibourhood of (316)727^3= 72045109, less than 19\\% of the worst case.","category":"page"},{"location":"Stop/#Estimation-of-f(\\alpha2)","page":"Estimation for a single qubit","title":"Estimation of f(alpha^2)","text":"","category":"section"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Often, the parameter that is to be measured is not alpha^2 but alpha=sqrt(alpha^2) or a differentiable function f of it. If f is continually differentiable, then sqrtNbig( f(hatp)-f(p) big) has an asymptotic normal distribution with mean 0 and variance f(p)^2 p(1-p). So,  using the same argument as in the previous section:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"beginaligned\r\n 1- gamma2 =  Pbigg -z  sqrtfracNf(p)^2 p(1-p)(f(hatp) - f(p) )  z bigg  \r\n= Pbigg -z sqrtfracf(p)^2 p(1-p)N  (hatp - p )  z sqrtfracf(p)^2 p(1-p)N bigg \r\nendaligned","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The length of the interval is therefore given by 2zsqrtf(p)^2 p(1-p)N and must be less or equal to 2Delta, hence:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"N = f(p)^2 p(1-p) bigg fracPhi^-1big( 1- gamma2 big)Delta bigg^2","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"We can now use the same sequential method","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"N = f(hatp)^2 hatp(1-hatp) bigg fracPhi^-1big( 1- gamma2 big)Delta bigg^2 = fbigg(fracS_NNbigg)^2 fracS_NF_NN^2 bigg fracPhi^-1big( 1- gamma2 big)Delta bigg^2","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"N= fbigg(fracS_NNbigg)^23 big( S_NF_N big)^13H(gammaDelta)","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"And samplig should continue until N is not greater than the right hand side of \\ref{eq.seq2}.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"As for the simpler case of estimating alpha^2, we need to deal with the cases of a long sequence of zeros, or ones which could happen when p=0 or p=1, but also when f(p)^2p(1-p) is small. But the way we solved the first situation also resolved the problem of a very small derivate. Since we'll be doing a minimal number of trials equal to log(1-gamma)log(1-Delta), then we know that, with probability no less than 1-gamma, that hatp-p  Delta. And if f(p)^2 le 1, then f(hatp)-f(p)  Delta with the same probability. We therefore have the necessary precision for small values of f(p)^2.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The stopping rule becomes:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Stop samplig when N ge maxbigg fraclog(1-gamma)log(1-Delta)  fbigg(fracS_NNbigg)^23big( S_NF_N big)^13H(gammaDelta) bigg","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"For example, with f(p)=sqrtp, we have:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"fbigg(fracS_NNbigg)^23big( S_NF_N big)^13=N^13frac1(4S_N)^13big( S_NF_N big)^13 =bigg(fracN4bigg)^13F_N^13","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"One last improvement could be to get rid of the derivative and estimate it instead of requiring the user to provide a function to do it. Let","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"D_N = big(f(S_NN+Delta)-f(S_NN-Delta)big)2Delta","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Then we have:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Stop samplig when N ge maxbigg fraclog(1-gamma)log(1-Delta)  D_N^23big( S_NF_N big)^13H(gammaDelta) bigg","category":"page"},{"location":"Stop/#Simultaneous-estimation-of-several-qubits","page":"Estimation for a single qubit","title":"Simultaneous estimation of several qubits","text":"","category":"section"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"If dealing with entangled qubits the measure is made on a multinomial distribution. For instance, the two qubits ketpsi_1psi_2 are in state alpha_00ket00+alpha_01ket01+alpha_10ket10+alpha_11ket11, where alpha_00^2+alpha_01^2+alpha_10^2+alpha_11^2 = 1. ","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Suppose K qubit are to be measured. Then, there are L=2^K possible measurement outcomes. The parameter p is not a scalar anymore but a 2^K-dimensional vector p_1p_L, representing the probability of each of the possible outcomes.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Let S_lN the proportion of time the the outcome l appeared and hatp_l=S_NN . Of course sum_l S_lN =N and sum_l hatp_l =1. The variance of hatp_l is equal to p_l(1-p_l)N and the correlation between hatp_l and hatp_m is given by -p_lp_mN.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The probability that all outcome estimate will be within less that Delta from their true values is difficult to compute exactly given the correlation. The simplest alternative is to use the Bonferonni method. If a global probability of 1- gamma is desired then the individual probability has to be set as 1-gammaL and use H(gammaL Delta) (\\ref{eq.H}) with the folloing rule:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Stop samplig when N ge maxbigg fraclog(1-gammaL)log(1-Delta)  max_l big( S_lNF_lN big)^13H(gammaLDelta) bigg","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"When estimating f(p_1p_L), where f    real^L to real. THen","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"f(hatp_1hatp_L)- f(p_1p_L) = fracpartial fpartial p_1(p)(hatp_1-p_1) +  + fracpartial fpartial p_L(p)(hatp_L-p_L)","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Hence","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Vbig( f(hatp_1hatp_L) big) = biggfracpartial fpartial p_1(p)bigg^2 Vbig(hatp_1big)+  + bigg fracpartial fpartial p_L(p)bigg^2 Vbig(hatp_Lbig)","category":"page"},{"location":"Stop/#Sampling-with-external-white-noise","page":"Estimation for a single qubit","title":"Sampling with external white noise","text":"","category":"section"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"So far we have assumed that, when measuring the qubit, the random variable X_n had a binomial distribution with parameter p = alpha^2. This will happen is there is no external noise disturbing the qubit. If this is not the case we can assume that the impact of the external noise is not correlated with the value of the qubit when it switches the lecture. In order to model this we introduce a new random variable Y_n that may change the value of the reading with probability 1-q. If Y_n = 0, then the reading is exact and equals X_n. But if Y_n =1 then output of the qubit is the opposit of the correct value. It will be 1 if X_n=0 and 0 if X_n=1.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"beginarrayccc\r\n  mbox   beginmatrix X_n=0  X_n = 1 endmatrix \r\n  beginmatrix Y_n=0  Y_n=1 endmatrix \r\n  beginbmatrix hspace10pt 0 hspace15pt  hspace15pt1 hspace10pt  hspace10pt 1hspace15pt  hspace15pt0 hspace10pt endbmatrix\r\nendarray","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"\\caption{Measured output Z_n depending on X_n and Y_n} \\end{figure}","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The impact of Y_n would be minimal on X_n if p=12 since the change form 0 to 1 would be, on average, ofset by the changes from 1 to 0. However, if p is closer to 0 or to 1, then there is a higher probability the one type of change will happen more frequently than the other. ","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"We have P(Z_n = 0) = P(X_n=0 cap Yn=0) + P(X_n = 1 cap Y_n = 1) = pq + (1-p)(1-q) = pq + 1 - q - p + pq = 1+2pq-p-q=p(2q-1)+(1-q). As we can see, there is a bias introduced in the measurement. So a simple average of the Z_n will lead to an estimation of p(2q-1)+(1-q) instead of the desired p. If q is known then ","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"hatp =fracN^-1sum_n=1^N Z_n -(1-q)(2q-1)","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"is an unbiased estimator for p and preferable to (\\ref{simpleEstim.eq}). If the noise is low, q will be close to 1 and 1-q near 0 and negligeable, while 2q-1 is almost equal to 1 and negligeable as well.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The variance of Z_n is then equal to (p+q-2pq)(1-p-q+2pq) and the variance of the estimator in (\\ref{unbiasEstim.eq}) is:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"V(hatp) =  frac(p+q-2pq)(1-p-q+2pq)N(2q-1)^2","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"And thre sample size can be treated similarly to the previous case as in (\\ref{Nchapeau.eq}). One can see that as q gets near 0.5 the variance will increase and require sample size much larger.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The value of q has to be known for (\\ref{unbiasEstim.eq}) to be useful. This can be based on past experiments made on the qubit and could be considered a calibrantion step.","category":"page"},{"location":"Stop/#White-noise-increasing-with-time","page":"Estimation for a single qubit","title":"White noise increasing with time","text":"","category":"section"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"In the previous section we have have assumed that the white noise Y_n was a random variable with a constant probability q of altering the outcome of the measurement. In reality, qubits will progressively become noisier as the time goes by. The probability q is in fact a function of time q(t) which is 0 when t=0 and prgressively increases to 0.5.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"A qubit is first initialised and them several calculation are done on it using logical gates. As these gates take a certain time to execute this must be added to the time of the qbit. If the time for each gate is a constant T_0 then the time to perform the computation on the qubit is equal to the number of gates multiplied by the time used to execute the gate: q(t) = q(T_0 times mboxNumber of gates in the computation)=q(T_0 K). The function q() could be approximated by an exponential such as:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"beginaligned\r\nq(t) = 05 big(1-e^-C_0 tbig) \r\n= 05 big(1- e^-C_0T_0 K big) \r\n= 05 big(1- e^-B_0 K big)\r\nendaligned","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"where B_0 is a constant for a given qubit. ","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"Inseting the last line of (\\ref{qExpo.eq}) into equations (\\ref{unbiasEstim.eq}) and (\\ref{varianceUnbiasEstim.eq}) we get:","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"hatp =fracN^-1sum_n=1^N Z_n -(1-05 big(1- e^-B_0 K big))(205 big(1- e^-B_0 K big)-1)","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"and","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"V(hatp) =  fracbig(p+05(1- e^-B_0 K)-2p05(1- e^-B_0 K)big) big(1-p-05(1- e^-B_0 K)+2p05(1- e^-B_0 K)big)Nbig( 205(1- e^-B_0 K )-1big)^2","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"V(hatp) =  fracbig(p+05(1- e^-B_0 K)-p(1- e^-B_0 K)big) big(1-p-05(1- e^-B_0 K)+p(1- e^-B_0 K)big)Nbig( (1- e^-B_0 K )-1big)^2","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"V(hatp) =  frac025 - big(p-05big)^2 e^-2B_0 K Ne^-2B_0 K","category":"page"},{"location":"Stop/#Computer-implementation","page":"Estimation for a single qubit","title":"Computer implementation","text":"","category":"section"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"The formula mentionned above are used by the classical computer controling the quantum computer. The circuit definition and measurement is send to the quantum computer by the classical one until the stopping rule is met. At that point the quantum computer is no more required.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"From an end-user point of view the methods are implemented using a class that takes as an input","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"A methods submitting the circuit definition and measuremnts once and returning the result in the form of an array of zeros and ones (the bits). \nThe number of bits returned must be specified as a second argument. \nA third argument is a function to be applied to the bits by the classical computer and returning a double precision number. If this argument is NULL then no function is applied. \nThe fourth argument is Delta and \nThe fifth one is the value of gamma.","category":"page"},{"location":"Stop/","page":"Estimation for a single qubit","title":"Estimation for a single qubit","text":"As a helped the user may want to know what is the expected number of runs the process may take in the worst case and some intermediary cases. A standalone program is provided where the user can provide the information and a report is produced giving some insight as to what may happen, including execution time.","category":"page"},{"location":"ToLaTeX/#Converting-a-QuantumCircuit-into-a-Quantikz/LaTeX-output","page":"Converting a QuantumCircuit into a Quantikz/LaTeX output","title":"Converting a QuantumCircuit into a Quantikz/LaTeX output","text":"","category":"section"},{"location":"ToLaTeX/","page":"Converting a QuantumCircuit into a Quantikz/LaTeX output","title":"Converting a QuantumCircuit into a Quantikz/LaTeX output","text":"A need to put some text here. This is new text as of September 12 at 07:07.","category":"page"},{"location":"#This-is-CRS-Quantum-Documentation","page":"This is CRS Quantum Documentation","title":"This is CRS Quantum Documentation","text":"","category":"section"},{"location":"","page":"This is CRS Quantum Documentation","title":"This is CRS Quantum Documentation","text":"The CRS Quantun package contains a set of useful functions for scientists using the Qube computer.","category":"page"},{"location":"","page":"This is CRS Quantum Documentation","title":"This is CRS Quantum Documentation","text":"stop\r\nSampleSize\r\nStatesProportions\r\nToLaTeX\r\nPlug\r\nConnector\r\nisinverse\r\nisbefore\r\nWire\r\nMQC\r\nMQCAddCircuit\r\nMQCAddConnector","category":"page"},{"location":"#Shovel.stop","page":"This is CRS Quantum Documentation","title":"Shovel.stop","text":"stop(fun::function, circuit::QuantumCircuit, Δ::Float64, γ::Float64, verbose=false)\n\nRuns a circuit until there is a probability 1-γ that the precision Δ is reached for each of the state measurements.\n\nArguments\n\nfun::function : is a function you want to calculate on the resulting proportion estimate on the final state of the circuit.\n\nThe function must take an array of Float64 as and input and return a Float64\n\ncircuit::QuantumCircuit: a QuantumCircuit as defined by Snowflake\nΔ::Float64: the difference between the real value and the estimation\nγ::Float64: the probability that the estimator is more that Δ apart from the true value. \n\nFor more details please see here.\n\nverbose::boolean: println usefull information on screen if needed for estimating suitable for Δ and γ. \n\nExample\n\njulia> stop(fun, circuit, 0.001, 0.10, sqrt)\n1\n\n\n\n\n\n","category":"function"},{"location":"#Shovel.SampleSize","page":"This is CRS Quantum Documentation","title":"Shovel.SampleSize","text":"SampleSize(c::QuantumCircuit)::Int64\n\nCalculate the sample size (number of shots) required to reach, with probability 1-γ, a difference not exceeding Δ between alpha_i^2 and the observed proportion p_i for all possible states in the sample.\n\nArguments\n\nc::QuantumCircuit: is a Snowflake cirquit.\n\nThe function return a positive integer\n\n\n\n\n\n","category":"function"},{"location":"#Shovel.StatesProportions","page":"This is CRS Quantum Documentation","title":"Shovel.StatesProportions","text":"StatesProportions is a structure containing the description and actual proportions of each state after a simulation \n\n\n\n\n\n","category":"type"},{"location":"#Shovel.ToLaTeX","page":"This is CRS Quantum Documentation","title":"Shovel.ToLaTeX","text":"ToLaTeX(c::QuantumCircuit, FName::String)\n\nWill generate a file containing the Latex/quantikz code in the standalone documentclass.\n\nArguments\n\ncircuit::QuantumCircuit: a QuantumCircuit as defined by Snowflake\nFName::String: the name of the file to create. Warning! It will overwrite if already existing. \n\nExample\n\njulia> ToLaTeX(circuit, \"Foo.bar\")\n\n\nThis is the standard output of a Snowflake circuit:\n\n(Image: Snowflake output)\n\nThis is the output file generated by ToLaTeX(). It can be copy&paste to any other Latex document.\n\n\\documentclass{standalone}\n\\usepackage{tikz}\n\\usetikzlibrary{quantikz}\n\\begin{document}\n\n\n\\begin{quantikz}\n\\lstick{q[1]: } &  \\gate{H} &  \\ctrl{1} &  \\gate{X} &  \\ctrl{1} &  \\qw &  \\qw &  \\qw &  \\ctrl{2} &  \\gate{Z} &  \\qw \\\\\n\\lstick{q[2]: } &  \\qw &  \\gate{X} &  \\qw &  \\gate{Z} &  \\qw &  \\qw &  \\ctrl{2} & \\qw &\\qw & \\qw \\\\\n\\lstick{q[3]: } &  \\qw &  \\qw &  \\qw &  \\qw &  \\gate{H} &  \\qw & \\qw & \\gate{Z} & \\qw & \\qw \\\\\n\\lstick{q[4]: } &  \\qw &  \\qw &  \\qw &  \\qw &  \\qw &  \\gate{H} &  \\gate{Z} &  \\qw &  \\ctrl{-3} &  \\qw \n\\end{quantikz}\n\\end{document}\n\nThis is the result of a pdfLaTeX compilation.\n\n(Image: ToLaTeX output)\n\n\n\n\n\n","category":"function"},{"location":"#Shovel.Plug","page":"This is CRS Quantum Documentation","title":"Shovel.Plug","text":"Plug is a structure containing the UUID of a circuit and a qubit number. It is the basic element of a Connector. The only validation done is that the qubit number of the circuit is valid (>0 and <=qubit_count). The operator \"==\" is defined for plugs.\n\n\n\n\n\n","category":"type"},{"location":"#Shovel.Connector","page":"This is CRS Quantum Documentation","title":"Shovel.Connector","text":"Connector is a structure containing two plugs: 1) the input plug which is when the qubit/circuit is coming from and 2) the output plug indicating to which qubit/circuit it is going to. Users can either create plugs and then a connector from them or directly create a connector by providing the circuit and the qubit. The operator \"==\" is defined for connectors.\n\n\n\n\n\n","category":"type"},{"location":"#Shovel.isinverse","page":"This is CRS Quantum Documentation","title":"Shovel.isinverse","text":"isinverse(connec1::Connector, connec2::Connector)::Boolean \n\nA function to checks if a given connector is the inverse of another one.     The function is used for internal consistency when a connector is added to an MQC. it will return true if          \"connec1.plugin == connec2.plugout && connec1.plugin == connec2.plugout\"         and false otherwise.\n\n\n\n\n\n","category":"function"},{"location":"#Shovel.isbefore","page":"This is CRS Quantum Documentation","title":"Shovel.isbefore","text":"isbefore(connec1::Connector, connec2::Connector)::Boolean \n\nA function to checks if the output plug of connec1 is the same as the input plug of connec2.     if true, it means that connec1 is just before connec2 and they are connected together in the same wire.\n\n\n\n\n\n","category":"function"},{"location":"#Shovel.Wire","page":"This is CRS Quantum Documentation","title":"Shovel.Wire","text":"structure Wire is a sequence of connector making a wire in the MQC.\n\n\n\n\n\n","category":"type"},{"location":"#Shovel.MQC","page":"This is CRS Quantum Documentation","title":"Shovel.MQC","text":"The structure MQC is the main element of the Meta Quantum Circuit utility. After adding quantum circuits (or \"circuits\" for short) and connectors, a quantikz/LaTeX file can be produced. Most importantly, a new circuit can be generated from the MQC. \n\n\n\n\n\n","category":"type"},{"location":"#Shovel.MQCAddCircuit","page":"This is CRS Quantum Documentation","title":"Shovel.MQCAddCircuit","text":"MQCAddCircuit(mqc::MQC, newc::QuantumCircuit)::Boolean \n\nThis function is used to add a Snowflake QuantumCircuit to an MQC.     A given circuit cannot be add twice ot the MQC. However, two distinct circuits with identical circuitry can.     The function will retrun true if the addition was successful.\n\n\n\n\n\n","category":"function"},{"location":"#Shovel.MQCAddConnector","page":"This is CRS Quantum Documentation","title":"Shovel.MQCAddConnector","text":"MQCAddConnector(mqc::MQC, connec::Connector)::Boolean \n\nThis function is used to add a connector to an MQC. It has some consistancy checks and will return     false if the proposed connector creates inconsistencies such as circular circuitry or duplicate plugs.\n\n\n\n\n\n","category":"function"}]
}
