import javax.xml.parsers.ParserConfigurationException;
import org.xml.sax.SAXException;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Objects;
import java.nio.file.Files;


public class Main {
    public static void main(String[] args) throws IOException, ParserConfigurationException, SAXException {
        if (args.length == 0) {

            System.out.println("This is EpiFusion, a program to model infection and Rt trajectories conditioned on both \n" +
                    "case incidence and phylogenetic tree data. This is a relatively new model \n" +
                    "so we suggest caution in its use, and are happy to hear any feedback about bugs or suggested \n" +
                    "improvements. Further information and example input XML files are available at the project github: \n" +
                    "https://github.com/ciarajudge/EpiFusion. To get started, rerun this command and include the path to \n" +
                    "an EpiFusion input file, as shown below:\n" +
                    "----\n" +
                    "Usage: java -jar EpiFusion.jar <path to xml file>\n"+
                    "----\n");

        } else if (args.length == 1) {

            System.out.println("This is EpiFusion, a program to model infection and Rt trajectories conditioned on both\n" +
                    "case incidence and phylogenetic tree data. This is a relatively new model \n" +
                    "so we suggest caution in its use, and are happy to hear any feedback about bugs or suggested \n" +
                    "improvements. Further information and example input XML files are available at the project github: \n" +
                    "https://github.com/ciarajudge/EpiFusion.\n");

            try {
                XMLParser.parseXMLInput(args[0]);
            } catch(FileNotFoundException e) {
                System.out.println("Error parsing the XML file " +args[0]+"; File Not Found!\n" +
                        "Make sure your file path is correct!\n");
            }

            Storage.loggers = Objects.equals(Storage.fileBase, "null") ? new MasterLoggers() : new MasterLoggers(Storage.fileBase);

            logXML(args[0]);

            long startTime = System.nanoTime();
            for (int i = 0; i < Storage.numChains; i++) {
                try {
                    ParticleFilter particleFilter = new ParticleFilter(i);
                    MCMC particleMCMC = new MCMC(particleFilter);
                    particleMCMC.runMCMC(Storage.numMCMCsteps);
                    particleMCMC.terminateLoggers();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }

            long endTime = System.nanoTime();
            System.out.println("Time elapsed: " + (endTime - startTime));
            FileWriter timings = new FileWriter(Storage.folder + "/timings.txt");
            timings.write(Long.toString((endTime - startTime)));
            timings.close();

        } else {

            System.out.println("Oops! It seems you have provided multiple command line arguments to the program. Reminder\n" +
                    "that the program takes a single path to an XML file as it's input:\n" +
                    "----" +
                    "Usage: java -jar EpiFusion.jar <path to xml file>\n"+
                    "----" +
                    "This is EpiFusion, a program to model infection and Rt trajectories conditioned on both \n" +
                    "case incidence and phylogenetic tree data. Further information and example input XML files are \n" +
                    "available at the project github: https://github.com/ciarajudge/EpiFusion.\n");

        }

    }

    public static void logXML(String xml) throws IOException {
        Path sourcePath = Paths.get(xml);
        Path destinationDir = Paths.get(Storage.folder);
        String fileName = sourcePath.getFileName().toString();
        Path destinationPath = destinationDir.resolve(fileName);
        Files.copy(sourcePath, destinationPath);
    }

}