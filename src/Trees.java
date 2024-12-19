import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.FileNotFoundException;
import org.w3c.dom.Element;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

public class Trees {
    public Tree[] trees;
    public int latest_root_node;

    public Trees(Element treeElement) throws IOException {
        Storage.phyloUncertainty = Boolean.parseBoolean(treeElement.getElementsByTagName("treePosterior").item(0).getTextContent());
        /*if (Storage.phyloUncertainty) {
            Storage.inferTOI = true;
        }*/
        latest_root_node = -2147483647;
        //Storage.maxTime = Integer.parseInt(treeElement.getElementsByTagName("maxTime").item(0).getTextContent());
        boolean treeStringExists = treeElement.getElementsByTagName("treeString").getLength() > 0;
        if (treeStringExists) {
            trees = new Tree[1];
            String treeString = treeElement.getElementsByTagName("treeString").item(0).getTextContent();
            trees[0] = new Tree(treeString);
            latest_root_node = Math.max(latest_root_node, (int) Math.ceil(trees[0].root.getTime()));
        } else {
            String treeFileName = treeElement.getElementsByTagName("treeFile").item(0).getTextContent();
            try {
                if (!Storage.phyloUncertainty) {
                    BufferedReader reader = new BufferedReader(new FileReader(treeFileName));
                    String newickString = reader.readLine();
                    reader.close();
                    trees = new Tree[1];
                    trees[0] = new Tree(newickString);
                    latest_root_node = Math.max(latest_root_node, (int) Math.ceil(trees[0].root.getTime()));
                } else {
                    List<String> allLines = Files.readAllLines(Paths.get(treeFileName));
                    trees = new Tree[allLines.size()];
                    int index = 0;
                    for (String line : allLines) {
                        trees[index] = new Tree(line);
                        latest_root_node = Math.max(latest_root_node, (int) Math.ceil(trees[index].root.getTime()));
                        index++;
                    }
                }
            } catch(FileNotFoundException e) {
                System.out.println("Error parsing the tree file " +treeFileName+";\n" +
                        "File Not Found! Make sure your file path is correct!\n");
            }
        }
    }

    public Trees() {
        this.trees = new Tree[1];
        this.trees[0] = null;
    }

    public void assembleSegmentedTrees(int end) {
        for (Tree tree : trees) {
            tree.getSegmentedTree(end);
        }
    }


}
