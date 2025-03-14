import java.io.File;
import java.util.Objects;
import java.util.Scanner;
import java.io.FileNotFoundException;
import org.w3c.dom.Element;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Arrays;
import javax.xml.parsers.*;
import org.w3c.dom.*;
import java.time.LocalDate;

public class Incidence {
    int [] incidence;
    int [] times;
    int length;
    int start = 0;
    int end;
    int earliest_case_data;
    public HashMap<Integer, Integer> pairedData;

    public Incidence(Element incidenceElement) throws FileNotFoundException {
        boolean incidenceFileExists = incidenceElement.getElementsByTagName("incidenceFile").getLength() > 0;
        if (incidenceFileExists) { //File will be a table of times and values
            String filename = incidenceElement.getElementsByTagName("incidenceFile").item(0).getTextContent();
            Scanner scanner = new Scanner(new File(filename));
            if (Objects.equals(Storage.dateAnchor,null)) {
                ArrayList<Integer> timeList = new ArrayList<>();
                ArrayList<Integer> valList = new ArrayList<>();
                while(scanner.hasNextLine()){
                    String line = scanner.nextLine();
                    String[] columns = line.split(",");
                    if(columns.length >= 2) {
                        timeList.add(Integer.parseInt(columns[0]));
                        valList.add(Integer.parseInt(columns[1]));
                    }
                }
                incidence = valList.stream().mapToInt(i->i).toArray();
                times = timeList.stream().mapToInt(i->i).toArray();
            } else {
                ArrayList<String> timeList = new ArrayList<>();
                ArrayList<Integer> valList = new ArrayList<>();
                while(scanner.hasNextLine()){
                    String line = scanner.nextLine();
                    String[] columns = line.split(",");
                    if(columns.length >= 2) {
                        timeList.add(columns[0]);
                        valList.add(Integer.parseInt(columns[1]));
                    }
                }
                incidence = valList.stream().mapToInt(i->i).toArray();
                String[] strings = timeList.toArray(new String[0]);
                times = new int [strings.length];
                for (int i = 0; i<strings.length; i++) {
                    times[i] = XMLParser.anchorDate(XMLParser.parseDate(strings[i]));
                }
            }
            length = incidence.length;
            end = times[length-1];
        } else {
            //Read in the incidence values
            String incidenceString = incidenceElement.getElementsByTagName("incidenceVals").item(0).getTextContent();
            String[] stringArray = incidenceString.split(" ");
            incidence = new int [stringArray.length];
            for (int i = 0; i<stringArray.length; i++) {
                incidence[i] = Integer.parseInt(stringArray[i]);
            }
            length = incidence.length;
            //Now let's deal with times
            if (incidenceElement.getElementsByTagName("incidenceTimes").getLength() > 0) {
                Element timesElement = (Element) incidenceElement.getElementsByTagName("incidenceTimes").item(0);
                String type = timesElement.getAttribute("type");
                String incidenceTimes = incidenceElement.getElementsByTagName("incidenceTimes").item(0).getTextContent();
                switch (type) {
                    case "default":
                        times = new int[length];
                        for (int i = 0; i < length; i++) {
                            times[i] = ((i + 1) * 7) - 1;
                        }
                        break;
                    case "every":
                        int every = Integer.parseInt(incidenceTimes);
                        times = new int[length];
                        for (int i = 0; i < length; i++) {
                            times[i] = ((i + 1) * every) - 1;
                        }
                        break;
                    case "exact":
                        if (Objects.equals(Storage.dateAnchor,null)) {
                            String[] stringTimes = incidenceTimes.split(" ");
                            times = new int [stringTimes.length];
                            for (int i = 0; i<stringTimes.length; i++) {
                                times[i] = Integer.parseInt(stringTimes[i]);
                            }
                            if (length != stringTimes.length) {
                                System.out.println("ERROR: the number of incidence times and incidence values do not match!");
                            }
                        } else {
                            String[] stringTimes = incidenceTimes.split(" ");
                            if (length != stringTimes.length) {
                                System.out.println("ERROR: the number of incidence times and incidence values do not match!");
                            }
                            times = new int [stringTimes.length];
                            for (int i = 0; i<stringTimes.length; i++) {
                                times[i] = XMLParser.anchorDate(XMLParser.parseDate(stringTimes[i]));
                            }
                        }
                        break;

                }
            } else {
                System.out.println("WARNING: No incidence times provided; using default");
                times = new int[length];
                for (int i = 0; i < length; i++) {
                    times[i] = (i + 1) * 7;
                }
            }
            end = times[length-1];
        }
        pairedData = new HashMap<>();
        for (int i = 0 ; i<times.length; i++) {
            pairedData.put(times[i], incidence[i]);
        }
        earliest_case_data = getFirstNonZeroKey(pairedData);
    }

    public static Integer getFirstNonZeroKey(HashMap<Integer, Integer> map) {
        int firstNonZeroKey = 2147483647;
        for (Map.Entry<Integer, Integer> entry : map.entrySet()) {
            if (entry.getValue() != 0) {
                firstNonZeroKey = Math.min(entry.getKey(), firstNonZeroKey);
            }
        }
        return firstNonZeroKey;
    }

}
