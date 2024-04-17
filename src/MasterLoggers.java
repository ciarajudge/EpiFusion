import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;


public class MasterLoggers {
    File folder;
    public FileWriter[] trajectories;
    public FileWriter[] likelihoods;
    public FileWriter[] params;
    public FileWriter[] acceptance;
    public FileWriter[] betas;
    private String filePath;

    public MasterLoggers(String filePath) throws IOException {
        folder = new File(filePath);
        if (!folder.exists()){
            folder.mkdir();
        }
        Storage.folder = filePath;
        this.filePath = filePath;
    }

    public MasterLoggers() throws IOException {
        LocalDateTime currentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        String folderName;
        String[] decomposedArgument = Storage.argument.split("/");
        String xmlFile = decomposedArgument[decomposedArgument.length-1];
        String dataCode = xmlFile.split("_")[0];
        System.out.println(dataCode);
        if (Storage.isPhyloOnly()) {
            folderName = dataCode+"_PhyloOnly_"+Storage.numParticles+"Particles_"+Storage.numMCMCsteps+"Steps_AnalysisType"+Storage.analysisType+"_"+currentDateTime.format(formatter);
        } else if (Storage.isEpiOnly()) {
            folderName = dataCode+"_EpiOnly_"+Storage.numParticles+"Particles_"+Storage.numMCMCsteps+"Steps_AnalysisType"+Storage.analysisType+"_"+currentDateTime.format(formatter);
        } else {
            folderName = dataCode+"_Combined_"+Storage.numParticles+"Particles_"+Storage.numMCMCsteps+"Steps_AnalysisType"+Storage.analysisType+"_"+currentDateTime.format(formatter);
        }

        String filePath = "/Users/ciarajudge/Desktop/PhD/EpiFusion_PublicationRepo/Scenario_Testing/Results2/"+folderName;
        this.filePath = filePath;
        Storage.folder = filePath;
        folder = new File(filePath);
        if (!folder.exists()) {
            folder.mkdir();
        }
    }


}