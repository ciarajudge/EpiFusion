import java.io.File;
import java.util.Scanner;
import java.io.FileNotFoundException;
public class Incidence {
    int [] incidence;
    int length;
    public Incidence(String filename) throws FileNotFoundException {
        Scanner scanner = new Scanner(new File(filename));
        incidence = new int [18];
        int i = 0;
        while(scanner.hasNextInt()){
            incidence[i++] = scanner.nextInt();
        }
        length = incidence.length;
    }

    public Incidence(String incidenceString, boolean notAFile) {
        String[] stringArray = incidenceString.split(" ");
        incidence = new int [stringArray.length];
        for (int i = 0; i<stringArray.length; i++) {
            System.out.println(Integer.parseInt(stringArray[i]));
            incidence[i] = Integer.parseInt(stringArray[i]);
        }
        length = incidence.length;
    }




}
