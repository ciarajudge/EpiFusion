import javax.xml.parsers.ParserConfigurationException;
import org.xml.sax.SAXException;

import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;
import java.nio.file.Files;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class Main {
    public static void main(String[] args) throws IOException, ParserConfigurationException, SAXException {
        System.out.println("EpiFusion");

        long startTime = System.nanoTime();

        XMLParser.parseXMLInput(args[0]);
        //Storage.tree.printTree();
        //Storage.printPriors();


        MasterLoggers loggers = Objects.equals(Storage.fileBase, "null") ? new MasterLoggers() : new MasterLoggers(Storage.fileBase);
        Storage.loggers = loggers;
        logXML(args[0]);

        //ExecutorService executor = Executors.newFixedThreadPool(Storage.numChains);
        for (int i=0; i<Storage.numChains; i++) {
            int finalI = i;
            //executor.submit(() -> {
                try {
                    ParticleFilter particleFilter = new ParticleFilter(finalI);
                    MCMC particleMCMC = new MCMC(particleFilter);
                    particleMCMC.runMCMC(Storage.numMCMCsteps);
                    particleMCMC.terminateLoggers();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            //});
        }
        //executor.shutdown();

        long endTime = System.nanoTime();
        System.out.println("Time elapsed: "+(endTime-startTime));
        FileWriter timings = new FileWriter(Storage.folder+"/timings.txt");
        timings.write(Long.toString((endTime - startTime)));
        timings.close();


    }

    public static void logXML(String xml) throws IOException {
        Path sourcePath = Paths.get(xml);
        Path destinationDir = Paths.get(Storage.folder);
        String fileName = sourcePath.getFileName().toString();
        Path destinationPath = destinationDir.resolve(fileName);
        Files.copy(sourcePath, destinationPath);
    }



}