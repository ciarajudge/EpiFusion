import java.io.File;
import java.io.FileWriter;
import java.io.FilterOutputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;


public class Loggers {
    File folder;
    public FileWriter trajectories;
    public FileWriter likelihoods;
    public FileWriter params;
    public FileWriter acceptance;
    public FileWriter completed;
    public FileWriter betas;
    public FileWriter Rs;
    public FileWriter positiveTests;
    private String filePath;
    private int chainID;

    public Loggers(int chainID) throws IOException {
        this.filePath = Storage.folder;
        this.chainID = chainID;
        startTrajectories();
        startLikelihoods();
        startParams();
        startAcceptance();
        startCompleted();
        startBetas();
        startRs();
        startPositiveTests();
    }


    public void startTrajectories() throws IOException {
        FileWriter trajectories = new FileWriter(filePath+"/trajectories_chain"+chainID+".csv");
        this.trajectories = trajectories;
        trajectoryHeader();
    }
    public void startLikelihoods() throws IOException {
        FileWriter likelihoods = new FileWriter(filePath+"/likelihoods_chain"+chainID+".txt");
        this.likelihoods = likelihoods;
    }
    public void startParams() throws IOException {
        FileWriter params = new FileWriter(filePath+"/params_chain"+chainID+".csv");
        this.params = params;
        paramsHeader();
    }
    public void startAcceptance() throws IOException {
        FileWriter acceptance = new FileWriter(filePath+"/acceptance_chain"+chainID+".txt");
        this.acceptance = acceptance;
    }
    public void startCompleted() throws IOException {
        FileWriter completed = new FileWriter(filePath+"/completed_chain"+chainID+".txt");
        this.completed = completed;
    }
    public void startBetas() throws IOException {
        FileWriter betas = new FileWriter(filePath+"/betas_chain"+chainID+".txt");
        this.betas = betas;
    }
    public void startRs() throws IOException {
        FileWriter Rs = new FileWriter(filePath+"/rt_chain"+chainID+".txt");
        this.Rs = Rs;
    }
    public void startPositiveTests() throws IOException {
        FileWriter positiveTests = new FileWriter(filePath+"/positivetests_chain"+chainID+".csv");
        this.positiveTests = positiveTests;
    }

    public void trajectoryHeader() throws IOException {
        String toWrite = "";
        for (int i = (Storage.resampleEvery*Storage.firstStep); i < Storage.T+1; i++) {
            toWrite = toWrite + "T_"+ i + ",";
        }
        toWrite = toWrite + "\n";
        //System.out.println(toWrite);
        trajectories.write(toWrite);
    }
    public void paramsHeader() throws IOException {
        String toWrite = "";
        for (int i=0; i<Storage.priors.labels.size(); i++) {
            toWrite = toWrite + Storage.priors.labels.get(i) + ",";
        }
        toWrite = toWrite + "\n";
        params.write(toWrite);
    }

    public void logTrajectory(Trajectory trajectory) throws IOException {
        String toWrite = "";
        for (Day d : trajectory.trajectory) {
            toWrite = toWrite + d.I + ",";
        }
        toWrite = toWrite + "\n";
        //System.out.println(toWrite);
        trajectories.write(toWrite);
    }
    public void logBeta(ArrayList<Double> betaArray) throws IOException {
        String toWrite = "";
        for (Double aDouble : betaArray) {
            toWrite = toWrite + aDouble + ",";
        }
        toWrite = toWrite + "\n";
        //System.out.println(toWrite);
        betas.write(toWrite);
    }
    public void logRs(ArrayList<Double> rArray) throws IOException {
        String toWrite = "";
        for (Double aDouble : rArray) {
            toWrite = toWrite + aDouble + ",";
        }
        toWrite = toWrite + "\n";
        //System.out.println(toWrite);
        Rs.write(toWrite);
    }
    public void logLogLikelihoodAccepted(Double likelihood) throws IOException {
        String toWrite = likelihood + "\n";
        this.likelihoods.write(toWrite);
    }
    public void logParams(double[] paramSet) throws IOException {
        String toWrite = "";
        for (Double param : paramSet) {
            toWrite = toWrite + param + ",";
        }
        toWrite = toWrite + "\n";
        this.params.write(toWrite);
    }
    public void logAcceptance(int accept) throws IOException {
        String toWrite = accept + "\n";
        this.acceptance.write(toWrite);
    }
    public void logCompleted(Double complete) throws IOException {
        String toWrite = complete + "\n";
        this.completed.write(toWrite);
    }

    public void logPositiveTests(ArrayList<Integer> positives) throws IOException {
        String toWrite = "";
        for (Integer p : positives) {
            toWrite = toWrite + p + ",";
        }
        toWrite = toWrite + "\n";
        //System.out.println(toWrite);
        positiveTests.write(toWrite);
    }

    /*
    public void logAllTrajectories(Particles particles) throws IOException {
        for (Particle p : particles.particles) {
            Trajectory trajectory = p.traj;
            String toWrite = "";
            for (Day d : trajectory.trajectory) {
                toWrite = toWrite + d.I + ",";
            }
            toWrite = toWrite + acceptance+ "\n";
            //System.out.println(toWrite);
            trajectories.write(toWrite);
        }
    }*/

    public void saveParticleLikelihoodBreakdown(double[][] likelihoodBreakdown, int step, double likelihood) throws IOException {
        FileWriter likelihoodBreakdownFile = new FileWriter(Storage.folder+"/likelihoodbreakdown_"+step+"_"+likelihood+".csv");
        for (double[] r : likelihoodBreakdown) {
            String toWrite = "";
            for (double c : r) {
                toWrite = toWrite + c + ",";
            }
            toWrite = toWrite + "\n";
            likelihoodBreakdownFile.write(toWrite);
        }
        likelihoodBreakdownFile.close();
    }

    public void flexiLogger(String filename, ArrayList<Double> list) throws IOException{
        FileWriter file = new FileWriter(filePath+"/"+filename+"_"+chainID);
        for (Double a:list) {
            file.write(a+"\n");
        }
        file.close();
    }

    public void flexiLogger(String filename, double[] list) throws IOException{
        FileWriter file = new FileWriter(filePath+"/"+filename+"_"+chainID);
        for (Double a:list) {
            file.write(a+"\n");
        }
        file.close();
    }

    public void terminateLoggers() throws IOException {
        trajectories.close();
        likelihoods.close();
        params.close();
        acceptance.close();
        betas.close();
        Rs.close();
        completed.close();
        positiveTests.close();
    }

}
