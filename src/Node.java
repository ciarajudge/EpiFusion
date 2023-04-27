import java.util.ArrayList;
import java.util.List;

public abstract class Node {
    private String label; // label of the node
    private double branchLength; // branch length of the node
    private List<Node> children; // children of the node
    private double time;

    public Node(String label) {
        this.label = label;
        this.branchLength = 0.0;
        this.children = new ArrayList<>();
    }

    public Node(String label, double branchLength, double time) {
        this.label = label;
        this.branchLength = branchLength;
        this.children = new ArrayList<>();
        this.time = time;
    }

    public void addChild(Node child) {
            children.add(child);
        }

        // Getters and setters
        // ...
    public void setLabel(String label) {
        this.label = label;
    }

    public void setTime(double time) {
        this.time = time;
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

    public double getBranchLength() {
        return this.branchLength;
    }

    public abstract boolean isLeaf();
}

class Leaf extends Node {
    public Leaf(String label, double branchLength, double time) {
        super(label, branchLength, time);
    }

    public boolean isLeaf(){
        return true;
    }
}

// Internal class representing an internal node in the tree
class Internal extends Node {
    public Internal(String label, double branchLength, double time) {
        super(label, branchLength, time);
    }

    public boolean isLeaf(){
        return false;
    }
}
