import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Stack;

public class Tree {
    // Leaf class representing a leaf node in the tree

    // Tree class representing a Newick format tree
    public final Node root; // root node of the tree

    public Tree(String fileName) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(fileName));
        String newickString = reader.readLine();
        reader.close();

        // Create a Tree object from the Newick format string
        this.root = parseNewickString(newickString);
    }

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

            //Otherwise just add it to its correct label
            else {
                if (readingLabel) {
                    label.append(c);
                } else if (readingBranchLength) {
                    branchLengthBuilder.append(c);
                }
            }
        }

        return current;
    }

    public Node getRoot() {
        return root; // Start printing from the root with initial indentation level 0
    }

    public void printTree() {
        System.out.println("Tree");
        System.out.println("root");
        printTree(root, 0); // Start printing from the root with initial indentation level 0
    }

    // Recursive method to print tree structure with indentation
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
    }

    private double getTime(String label) {
        int startIndex = label.indexOf("[") + 1;
        int endIndex = label.indexOf("]");
        String numberStr = label.substring(startIndex, endIndex);
        return Double.parseDouble(numberStr);
    }

}
