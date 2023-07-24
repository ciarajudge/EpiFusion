import org.apache.commons.math3.distribution.PoissonDistribution;

public class ProcessModel {

    public static void day(Particle particle, TreeSegment tree, int t, double[] rates) {
        //Check if the particle phylo likelihood is negative infinity, if so just quit
        if (particle == null) {
            System.out.println("null particle here ProcessMod line 9");
        }

        if (Double.isInfinite(particle.getPhyloLikelihood())) {
            return;
        }

        int state = particle.getState();
        if (Storage.analysisType == 1) {
            particle.nextBeta(rates[4]);
            rates[0] = particle.beta.get(particle.beta.size()-1);
        }
        double[] propensities = particle.getVanillaPropensities(rates);

        if (tree.lineages == 0) { //this means the tree must start in this interval, so we do a new propensity calc
            double segmentBeginning = t + 1 - tree.birthTimes.get(0);
            double segmentEnding = 1 - segmentBeginning;
            int newBirths = poissonSampler(propensities[0]*segmentBeginning);
            state = state + newBirths;
            propensities = transformPropensities(propensities, segmentEnding);
        }


        //Divide the propensities into their bits
        double unobservedInfectProp = state > 0
                ? propensities[0] * (1.0 - tree.lineages * (tree.lineages - 1) / (double) state/(state+1))
                : 0.0;
        //System.out.println("Day "+t+" Particle "+particle.particleID+" state: "+state+", unobserved infect prop: "+unobservedInfectProp+", and full infect prop "+propensities[0]);
        if (unobservedInfectProp < 0.0) {
            /*System.out.println("WARNING: Particle "+particle.particleID+" unobserved infection propensity " +
                    "for day "+t+" is negative! This will disrupt the process model for the rest of the filter step!"+
                    " Returning neg infinity for the particle.");
            */
            particle.setPhyloLikelihood(Double.NEGATIVE_INFINITY);

            return;
        }
        //System.out.println("unobserved infection prop: "+unobservedInfectProp);

        double observedInfectProp = propensities[0] - unobservedInfectProp;
        double allowedRecovProp, forbiddenRecovProp;
        if (state > tree.lineages + propensities[1] +tree.samplings) { //Previous version of this was: tree.lineages + propensities[1] + tree.samplings + 1 (stops recov past limit issue)
            allowedRecovProp = propensities[1];
            forbiddenRecovProp = 0.0;
        }
        else {
            allowedRecovProp = 0.0;
            forbiddenRecovProp = propensities[1];
        }
        //System.out.println("allowed recov prop: "+allowedRecovProp);
        double sampleProp = propensities[2];
        if (tree.lineages < 1 && t > 1) {
            unobservedInfectProp = propensities[0];
            allowedRecovProp = propensities[1];
        } else if (tree.lineages < 1) {
            //System.out.println("No tree yet.");
            unobservedInfectProp = propensities[0];
            allowedRecovProp = 0.0;
        }
        //Calculate the events
        int births = poissonSampler(unobservedInfectProp);
        //System.out.println("births: "+births);
        int deaths = poissonSampler(allowedRecovProp);
        //System.out.println("deaths: "+deaths);
        state = state + births - deaths;
        particle.setState(state);
        if (tree.lineages > 0) {
            double[] adjustedPropensities = new double[]{observedInfectProp, unobservedInfectProp, allowedRecovProp, forbiddenRecovProp, sampleProp};
            //System.out.println("adjusted propensities: "+Arrays.toString(adjustedPropensities));
            double todayPhyloLikelihood = PhyloLikelihood.calculateLikelihood(tree, particle, adjustedPropensities);
            System.out.println("Day "+t+", Particle "+particle.particleID+", Truth: "+Storage.truth[t]+" State:"+particle.getState()+" Phylo Likelihood: " +todayPhyloLikelihood);
            if (Double.isInfinite(todayPhyloLikelihood)) {
                //System.out.println("WARNING: Particle "+particle.particleID+" likelihood for day "+t+" is Infinity!");
                /*
                System.out.println("["+particle.particleID+"]State pre phylo likelihood calc: "+state);
                System.out.println("["+particle.particleID+"]State post phylo likelihood calc: "+particle.getState());
                System.out.println("["+particle.particleID+"]Likelihood: "+todayPhyloLikelihood);
                System.out.println("["+particle.particleID+"]Tree lineages: "+tree.lineages);
                System.out.println("["+particle.particleID+"]Unobserved births: "+births);
                System.out.println("["+particle.particleID+"]Deaths: "+deaths);
                System.out.println("["+particle.particleID+"]Adjusted propensities: "+Arrays.toString(adjustedPropensities)); */
                particle.setPhyloLikelihood(Double.NEGATIVE_INFINITY); //set phylo Likelihood of that particle to negative infinity which will quit the loop
                return;
            }

            particle.setPhyloLikelihood(particle.getPhyloLikelihood()+todayPhyloLikelihood);
            //System.out.println("Overall Phylo Likelihood: "+particle.getPhyloLikelihood());
        } else {
            particle.setState(particle.getState()+tree.births);
        }
        Day tmpDay = new Day(t, particle.getState(), births, deaths);
        particle.updateTrajectory(tmpDay);
    }

    public static void step(Particle particle, TreeSegment[] treeSegments, int step, double[][] rates) {
        int t = step*Storage.resampleEvery;
        int increments = treeSegments.length;
        for (int i=0; i<increments; i++) {
            //Turn on tree if we've reached it
            int actualDay = t+i;
            //System.out.println("\nDay "+actualDay);


            if (!Storage.treeOn[particle.particleID] && !(treeSegments[i].lineages == 0 && treeSegments[i].births == 0)) { //So if storage is false, and (characteristics of an inactive tree) is false, this means it's time to activate the tree
                Storage.treeOn[particle.particleID] = true;
                Storage.haveReachedTree[particle.particleID] = true;
            } else if (Storage.haveReachedTree[particle.particleID] && (treeSegments[i].lineages == 0 && treeSegments[i].births == 0)) {
                Storage.treeOn[particle.particleID] = false;
            }

            if (Storage.treeOn[particle.particleID]) { //If the tree is on we can just do the day no questions asked
                if (!Storage.segmentedDays) {
                    day(particle, treeSegments[i], actualDay, rates[i]);
                } else {
                    segmentedDay(particle, treeSegments[i], actualDay, rates[i]);
                }
            } else if (!(Storage.isPhyloOnly())) { //If tree is off but we are running a combo this means we can use the epi only day
                epiOnlyDay(particle, actualDay, rates[i]);
            } else if (Storage.isPhyloOnly()) { //If tree is off and we are phylo only we first need to know if it's before or after tree activation
                if (Storage.haveReachedTree[particle.particleID]) {
                    //System.out.println("Tree finished, quitting");
                    break;
                } else {
                    //System.out.println("Day "+actualDay+" tree not active yet");
                    //System.out.println("Sending particle "+particle.particleID+" for an epi only day");
                    epiOnlyDay(particle, actualDay, rates[i]);
                }
            }

        }
    }

    public static int poissonSampler(double rate) {
        if (rate == 0.0) {
            return 0;
        }
        PoissonDistribution poissonDistribution = new PoissonDistribution(rate);
        return poissonDistribution.sample();
    }

    public static void epiOnlyDay(Particle particle, int t, double[] rates) {
        //Check if the particle phylo likelihood is negative infinity, if so just quit
        int state = particle.getState();
        if (state <= 0) {
            Day tmpDay = new Day(t, state, 0, 0);
            particle.updateTrajectory(tmpDay);
            return;
        }
        //System.out.println("EpiOnlyDay "+t+" Particle "+particle.particleID+" state: "+state);
        if (Storage.analysisType == 1) {
            particle.nextBeta(rates[4]);
            rates[0] = particle.beta.get(particle.beta.size()-1);
        }

        double[] propensities = particle.getVanillaPropensities(rates);

        //Calculate the events
        int births = poissonSampler(propensities[0]);
        //System.out.println("[Day "+t+" Particle "+particle.particleID+"]"+"births: "+births);
        int deaths = poissonSampler(propensities[1]);
        //System.out.println("[Day "+t+" Particle "+particle.particleID+"]"+"deaths: "+deaths);
        state = state + births - deaths;
        particle.setState(state);
        Day tmpDay = new Day(t, particle.getState(), births, deaths);
        particle.updateTrajectory(tmpDay);
    }

    public static void epiOnlyStep(Particle particle, int step, double[][] rates, int increments) {
        int t = step*Storage.resampleEvery;
        for (int i=0; i<increments; i++) {
            int actualDay = t+i;
            //System.out.println("Sending particle "+particle.particleID+" for day "+actualDay+", State currently: "+particle.getState());
            epiOnlyDay(particle, actualDay, rates[i]);
        }

    }

    public static double[] transformPropensities(double[] propensities, double segmentTime) {
        double[] newPropensities = new double[propensities.length];
        for ( int i=0; i<propensities.length; i++){
            newPropensities[i] = propensities[i] * segmentTime;
        }
        return newPropensities;
    }


    public static void segmentedDay(Particle particle, TreeSegment tree, int t, double[] rates) {
        //Check if the particle phylo likelihood is negative infinity, if so just quit
        if (Double.isInfinite(particle.getPhyloLikelihood())) {
            return;
        }

        //If beta is RW, get new propensity[0]
        if (Storage.analysisType == 1) {
            particle.nextBeta(rates[4]);
            rates[0] = particle.beta.get(particle.beta.size()-1);
        }

        int prevState = particle.getState();
        double prevLikelihood = particle.getPhyloLikelihood();
        double deltaT, nextT;
        double currentT = t;
        int state, births, deaths, eventType;
        double[] propensities, adjustedPropensities;
        double unobservedInfectProp, observedInfectProp, allowedRecovProp, forbiddenRecovProp, sampleProp;
        int treeLineages = tree.lineages;

        //Loop through thingy
        for (int e = 0; e < tree.observationOrder.length + 1; e++ ) {
            //Figure out what the segment time is
            nextT = e == tree.observationOrder.length ? t+1 : tree.observationTimes.get(e);
            deltaT = nextT - currentT;

            //Get propensities and state
            state = particle.getState();
            propensities = particle.getSegmentPropensities(rates, deltaT);

            //Adjust the propensities
            unobservedInfectProp = state > 0
                    ? propensities[0] * (1.0 - treeLineages * (treeLineages - 1) / (double) state/(state+1))
                    : 0.0;
            if (unobservedInfectProp < 0.0) {
                particle.setPhyloLikelihood(Double.NEGATIVE_INFINITY);
                return;
            }
            observedInfectProp = propensities[0] - unobservedInfectProp;
            if (state > treeLineages + propensities[1]) { //Previous version of this was: tree.lineages + propensities[1] + tree.samplings + 1 (stops recov past limit issue)
                allowedRecovProp = propensities[1];
                forbiddenRecovProp = 0.0;
            } else {
                allowedRecovProp = 0.0;
                forbiddenRecovProp = propensities[1];
            }
            sampleProp = propensities[2];

            //Increment the states
            births = poissonSampler(unobservedInfectProp);
            deaths = poissonSampler(allowedRecovProp);
            state = state + births - deaths;
            particle.setState(state);


            //Phylo likelihood calculation
            adjustedPropensities = new double[]{observedInfectProp, unobservedInfectProp, allowedRecovProp, forbiddenRecovProp, sampleProp};
            eventType = nextT == t+1 ? 2 : tree.observationOrder[e];
            double todayPhyloLikelihood = PhyloLikelihood.calculateSegmentLikelihood(particle, adjustedPropensities, eventType);
            if (Double.isInfinite(todayPhyloLikelihood) || Double.isNaN(todayPhyloLikelihood)) {
                particle.setPhyloLikelihood(Double.NEGATIVE_INFINITY);
                return;
            }
            particle.setPhyloLikelihood(particle.getPhyloLikelihood()+todayPhyloLikelihood);

            //Adjust treeLineages and nextT
            currentT = nextT;
            if (eventType == 0) {
                treeLineages += 1;
            } else if (eventType == 1) {
                treeLineages -= 1;
            }
        }

        /*System.out.println("["+particle.particleID+"] Day "+t+", TrueState "+Storage.truth[t]+", ParticleState "+particle.getState()+
                ", TrueChange "+(Storage.truth[t]-Storage.truth[t-1])+", ParticleChange "+(particle.getState()-prevState)+
                ", PhyloLikelihood "+(particle.getPhyloLikelihood()-prevLikelihood));*/
        Day tmpDay = new Day(t, particle.getState(), 0, 0);
        particle.updateTrajectory(tmpDay);
    }



    public static void bruteForceTruth(Particle particle, TreeSegment tree, int t, double[] rates) {
        //Check if the particle phylo likelihood is negative infinity, if so just quit
        if (Double.isInfinite(particle.getPhyloLikelihood())) {
            return;
        }

        int state = particle.getState();
        if (Storage.analysisType == 1) {
            particle.nextBeta(rates[4]);
            rates[0] = particle.beta.get(particle.beta.size()-1);
        }
        double[] propensities = particle.getVanillaPropensities(rates);

        if (tree.lineages == 0) { //this means the tree must start in this interval, so we do a new propensity calc
            double segmentBeginning = t + 1 - tree.birthTimes.get(0);
            double segmentEnding = 1 - segmentBeginning;
            int newBirths = Storage.births[t] - tree.births;
            int newDeaths = Storage.deaths[t];
            state = state + newBirths - newDeaths;
            propensities = transformPropensities(propensities, segmentEnding);
        }


        //Divide the propensities into their bits
        double unobservedInfectProp = state > 0
                ? propensities[0] * (1.0 - tree.lineages * (tree.lineages - 1) / (double) state/(state+1))
                : 0.0;
        if (unobservedInfectProp < 0.0) {
            System.out.println("WARNING: Particle "+particle.particleID+" unobserved infection propensity " +
                    "for day "+t+" is negative! This will disrupt the process model for the rest of the filter step!"+
                    " Returning neg infinity for the particle.");
            particle.setPhyloLikelihood(Double.NEGATIVE_INFINITY);
            return;
        }

        double observedInfectProp = propensities[0] - unobservedInfectProp;
        double allowedRecovProp, forbiddenRecovProp;
        if (state > tree.lineages + propensities[1]) {
            allowedRecovProp = propensities[1];
            forbiddenRecovProp = 0.0;
        }
        else {
            allowedRecovProp = 0.0;
            forbiddenRecovProp = propensities[1];
        }
        double sampleProp = propensities[2];
        if (tree.lineages < 1 && t > 1) {
            unobservedInfectProp = propensities[0];
            allowedRecovProp = propensities[1];
        } else if (tree.lineages < 1) {
            //System.out.println("No tree yet.");
            unobservedInfectProp = propensities[0];
            allowedRecovProp = 0.0;
        }

        //Calculate the events
        int births = Storage.births[t] - tree.births;
        int deaths = Storage.deaths[t];
        state = state + births - deaths;
        particle.setState(state);

        if (tree.lineages > 0) {
            double[] adjustedPropensities = new double[]{observedInfectProp, unobservedInfectProp, allowedRecovProp, forbiddenRecovProp, sampleProp};
            //System.out.println("adjusted propensities: "+Arrays.toString(adjustedPropensities));
            double todayPhyloLikelihood = PhyloLikelihood.calculateLikelihood(tree, particle, adjustedPropensities);
            System.out.println("Day "+t+", Particle "+particle.particleID+", Truth: "+Storage.truth[t]+" State:"+particle.getState()+" Phylo Likelihood: " +todayPhyloLikelihood);
            if (Double.isInfinite(todayPhyloLikelihood)) {
                particle.setPhyloLikelihood(Double.NEGATIVE_INFINITY); //set phylo Likelihood of that particle to negative infinity which will quit the loop
                return;
            }

            particle.setPhyloLikelihood(particle.getPhyloLikelihood()+todayPhyloLikelihood);
            //System.out.println("Overall Phylo Likelihood: "+particle.getPhyloLikelihood());
        } else {
            particle.setState(particle.getState()+tree.births);
        }
        Day tmpDay = new Day(t, particle.getState(), births, deaths);
        particle.updateTrajectory(tmpDay);
    }

}
