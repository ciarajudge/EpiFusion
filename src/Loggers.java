import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Loggers {
    File folder;
    public FileWriter trajectories;
    public FileWriter likelihoodsall;
    public FileWriter likelihoods;
    public FileWriter params;
    public FileWriter acceptance;

    public Loggers(String filePath) throws IOException {
        folder = new File(filePath);
        if (!folder.exists()){
            folder.mkdir();
        }
        trajectories = new FileWriter(filePath+"/trajectories.csv");
        trajectoryHeader();
        likelihoods = new FileWriter(filePath+"/likelihoods.txt");
        likelihoodsall = new FileWriter(filePath+"/likelihoodsall.txt");
        params = new FileWriter(filePath+"/params.txt");
        acceptance = new FileWriter(filePath+"/acceptance.txt");
    }

    public Loggers() throws IOException {
        LocalDateTime currentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        String folderName;
        if (Storage.isPhyloOnly()) {
            folderName = "PhyloOnly_"+Storage.numParticles+"Particles_"+Storage.numMCMCsteps+"Steps_"+currentDateTime.format(formatter);
        } else if (Storage.isEpiOnly()) {
            folderName = "EpiOnly_"+Storage.numParticles+"Particles_"+Storage.numMCMCsteps+"Steps_"+currentDateTime.format(formatter);
        } else {
            folderName = "Combined_"+Storage.numParticles+"Particles_"+Storage.numMCMCsteps+"Steps_"+currentDateTime.format(formatter);
        }
        String filePath = "/Users/ciarajudge/Desktop/PhD/EpiFusionResults/"+folderName;
        folder = new File(filePath);
        if (!folder.exists()){
            folder.mkdir();
        }
        //System.out.println(filePath);
        trajectories = new FileWriter(filePath+"/trajectories.csv");
        trajectoryHeader();
        likelihoods = new FileWriter(filePath+"/likelihoods.txt");
        likelihoodsall = new FileWriter(filePath+"/likelihoodsall.txt");
        params = new FileWriter(filePath+"/params.txt");
        acceptance = new FileWriter(filePath+"/acceptance.txt");
    }

    public void logTrajectory(Trajectory trajectory) throws IOException {
        String toWrite = "";
        for (Day d : trajectory.trajectory) {
            toWrite = toWrite + d.I + ",";
        }
        toWrite = toWrite + "\n";
        System.out.println(toWrite);
        trajectories.write(toWrite);
    }

    public void trajectoryHeader() throws IOException {
        String toWrite = "";
        for (int i = 0; i < Storage.T+1; i++) {
            toWrite = toWrite + "T_"+ i + ",";
        }
        toWrite = toWrite + "\n";
        //System.out.println(toWrite);
        trajectories.write(toWrite);
    }



    public void logLogLikelihoodAccepted(Double likelihood) throws IOException {
        String toWrite = likelihood + "\n";
        likelihoods.write(toWrite);
    }
    public void logLogLikelihood(Double likelihood) throws IOException {
        String toWrite = likelihood + "\n";
        likelihoodsall.write(toWrite);
    }

    public void logParams(double[] paramSet) throws IOException {
        String toWrite = "";
        for (Double param : paramSet) {
            toWrite = toWrite + param + ",";
        }
        toWrite = toWrite + "\n";
        params.write(toWrite);
    }
    public void logAcceptance(int accept) throws IOException {
        String toWrite = accept + "\n";
        acceptance.write(toWrite);
    }

    public void logTrajectory(Trajectory trajectory, String acceptance) throws IOException {
        String toWrite = "";
        for (Day d : trajectory.trajectory) {
            toWrite = toWrite + d.I + ",";
        }
        toWrite = toWrite + acceptance+ "\n";
        //System.out.println(toWrite);
        trajectories.write(toWrite);
    }

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
    }


    public void terminateLoggers() throws IOException {
        trajectories.close();
        likelihoods.close();
        likelihoodsall.close();
        params.close();
        acceptance.close();
    }

}
