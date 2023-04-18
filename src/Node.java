import java.util.ArrayList;
import java.util.List;

public class Node {
    private String label; // label of the node
    private double branchLength; // branch length of the node
    private List<Node> children; // children of the node

    public Node(String label) {
        this.label = label;
        this.branchLength = 0.0;
        this.children = new ArrayList<>();
    }

    public Node(String label, double branchLength) {
        this.label = label;
        this.branchLength = branchLength;
        this.children = new ArrayList<>();
    }

    public void addChild(Node child) {
            children.add(child);
        }

        // Getters and setters
        // ...
    public void setLabel(String label) {
        this.label = label;
    }

    public void setBranchLength(double branchLength) {
        this.branchLength = branchLength;
    }

    public String getLabel() {
        return this.label;
    }

    public List<Node> getChildren() {
        return this.children;
    }
}

class Leaf extends Node {
    public Leaf(String label, double branchLength) {
        super(label, branchLength);
    }
}

// Internal class representing an internal node in the tree
class Internal extends Node {
    public Internal(String label, double branchLength) {
        super(label, branchLength);
    }
}
