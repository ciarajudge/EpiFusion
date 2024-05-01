import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Stack;

public class Tree {
    // Leaf class representing a leaf node in the tree

    // Tree class representing a Newick format tree
    public final Node root; // root node of the tree
    public double age;
    public int start = 0;
    public int end;
    public TreeSegment[] segmentedTree;

    public Tree(String fileName) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(fileName));
        String newickString = reader.readLine();
        reader.close();
        this.age = 0.0;
        // Create a Tree object from the Newick format string
        this.root = parseNewickString(newickString);
        this.end = (int) Math.ceil(age);
    }


    public Tree(String treeString, boolean isString) throws IOException {
        this.age = 0.0;
        // Create a Tree object from the Newick format string
        this.root = parseNewickString(treeString);
        this.end = (int) Math.ceil(age);

    }



    //Read-in utilities
    private Node parseNewickString(String newickString) {
        double time = 0.0;
        Stack<Node> stack = new Stack<>();
        Node current = null;
        StringBuilder label = new StringBuilder();
        StringBuilder branchLengthBuilder = new StringBuilder();
        double branchLength;
        boolean readingLabel = false;
        boolean readingBranchLength = false;
        boolean isLeaf = true;

        //Loop through each char in the string
        for (int i=0; i<newickString.length(); i++) {

            char c = newickString.charAt(i);
            //If char is an opening parenthesis, push a new node onto the stack
            if (c == '(') {
                if (current != null) {
                    stack.push(current);
                }
                current = new Internal("", 0.0, time);
                isLeaf = true;
                readingLabel = true;
                readingBranchLength = false;
            }
            /*If char is a closing parenthesis, either wrap up the label and branch length
            into a leaf node or wrap up the current internal node
             */

            else if (c == ')') {
                if (isLeaf) {
                    branchLength = Double.parseDouble(branchLengthBuilder.toString());
                    String lbl = label.toString();
                    time = getTime(lbl);
                    age = Math.max(time, age);
                    assert current != null;
                    current.addChild(new Leaf(lbl, branchLength, time));
                    label.setLength(0);
                    branchLengthBuilder.setLength(0);
                } else {
                    if (!stack.isEmpty()) {
                        branchLength = Double.parseDouble(branchLengthBuilder.toString());
                        String lbl = label.toString();
                        current.setBranchLength(branchLength);
                        current.setLabel(lbl);
                        time = getTime(lbl);
                        current.setTime(time);
                        Node parent = stack.pop();
                        parent.addChild(current);
                        current = parent;
                        label.setLength(0);
                        branchLengthBuilder.setLength(0);
                    }
                }
                isLeaf = false;
                readingLabel = true;
                readingBranchLength = false;
            }

            /*If char is a comma, either wrap up the label and branch length into a leaf node
            or it's an internal node
             */
            else if (c == ',') {
                if (isLeaf) {
                    branchLength = Double.parseDouble(branchLengthBuilder.toString());
                    String lbl = label.toString();
                    time = getTime(lbl);
                    age = Math.max(time, age);
                    assert current != null;
                    current.addChild(new Leaf(lbl, branchLength, time));
                    label.setLength(0);
                    branchLengthBuilder.setLength(0);
                } else {
                    if (!stack.isEmpty()) {
                        branchLength = Double.parseDouble(branchLengthBuilder.toString());
                        String lbl = label.toString();
                        current.setBranchLength(branchLength);
                        current.setLabel(lbl);
                        time = getTime(lbl);
                        current.setTime(time);
                        Node parent = stack.pop();
                        parent.addChild(current);
                        current = parent;
                        label.setLength(0);
                        branchLengthBuilder.setLength(0);
                    }
                }
                isLeaf = true;
                readingLabel = true;
                readingBranchLength = false;
            }

            //If char is a colon it's time to read branch length
            else if (c == ':') {
                readingLabel = false;
                readingBranchLength = true;
            }

            //If char is a semicolon it's time to break the loop
            else if (c == ';') {
                break;
            }

            //Otherwise just add it to its correct label
            else {
                if (readingLabel) {
                    label.append(c);
                } else if (readingBranchLength) {
                    branchLengthBuilder.append(c);
                }
            }
        }
        branchLength = Double.parseDouble(branchLengthBuilder.toString());
        String lbl = label.toString();
        current.setBranchLength(branchLength);
        current.setLabel(lbl);
        time = getTime(lbl);
        current.setTime(time);
        current.isRoot = true;
        return current;
    }
    private double getTime(String label) {
        int startIndex = label.indexOf("[") + 1;
        int endIndex = label.indexOf("]");
        String numberStr = label.substring(startIndex, endIndex);
        return Double.parseDouble(numberStr);
    }

    //Getters
    public Node getRoot() {
        return root; // Start printing from the root with initial indentation level 0
    }

    //Printing
    public void printTree() {
        System.out.println("Tree");
        printTree(root, 0); // Start printing from the root with initial indentation level 0
    }
    private void printTree(Node node, int indentation) {
        if (node != null) {
            // Print indentation for the current level
            for (int i = 0; i < indentation; i++) {
                System.out.print("    "); // Four spaces per level of indentation
            }

            // Print node label
            System.out.println(node.getLabel());

            // Print children nodes recursively with increased indentation level
            for (Node child : node.getChildren()) {
                printTree(child, indentation + 1);
            }
        }
    }  // Recursive method to print tree structure with indentation
    public void printTreeInSegments(int maxTime) {
        for (int i=0; i<maxTime; i++) {
            double end = (double) i + 1;
            TreeSegment treeSegment = new TreeSegment(this, i, end);
            treeSegment.printTreeSegment();
        }
    }

    public void treeEventsInSegments(int maxTime) {
        int eventsInTree = 0;
        int eventsInSegment = 0;
        for (int i=0; i<maxTime; i++) {
            eventsInSegment = 0;
            double end = (double) i + 1;
            TreeSegment treeSegment = new TreeSegment(this, i, end);
            eventsInSegment += treeSegment.births + treeSegment.samplings;
            eventsInTree += Integer.max(0, eventsInSegment);
        }
        System.out.println("Events in tree: "+eventsInTree);
    }

    //Check if tree is 'active'
    public boolean treeFinished(int step){
        boolean treeFinished = false;
        if (step < 2) {
            return treeFinished;
        }
        int time = step*Storage.resampleEvery;
        TreeSegment segment = new TreeSegment(this, (double) time, time+ 1.0);
        if (segment.lineages == 0) {
            treeFinished = true;
        }
        return treeFinished;
    }

}
