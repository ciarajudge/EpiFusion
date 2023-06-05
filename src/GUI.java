import java.awt.*;
import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
class GUI {
    private boolean buttonClicked;

        public void showDialog() {
            JDialog dialog = new JDialog();
            dialog.setTitle("My Dialog Box");
            dialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
            dialog.setSize(400, 300);
            dialog.setLayout(new BorderLayout());

            // Panel for the logo and package name
            JPanel headerPanel = new JPanel();
            headerPanel.setLayout(new FlowLayout(FlowLayout.CENTER));

            // Logo
            ImageIcon logoIcon = new ImageIcon("logo.png"); // Path to your logo image file
            JLabel logoLabel = new JLabel(logoIcon);

            // Package name
            JLabel packageLabel = new JLabel("My Java Package");
            packageLabel.setFont(new Font("Arial", Font.BOLD, 18));

            // Adding logo and package name to header panel
            headerPanel.add(logoLabel);
            headerPanel.add(packageLabel);

            // Panel for the button and slider
            JPanel contentPanel = new JPanel();
            contentPanel.setLayout(new FlowLayout(FlowLayout.CENTER));

            // Button
            JButton button = new JButton("Click Me!");

            // Add action listener to the button
            button.addActionListener(new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent e) {
                    buttonClicked = true;
                    dialog.dispose(); // Close the dialog box
                }
            });

            // Slider
            JSlider slider = new JSlider(JSlider.HORIZONTAL, 0, 100, 50);
            slider.setMajorTickSpacing(20);
            slider.setPaintTicks(true);
            slider.setPaintLabels(true);

            // Adding button and slider to content panel
            contentPanel.add(button);
            contentPanel.add(slider);

            // Adding header panel and content panel to the dialog
            dialog.add(headerPanel, BorderLayout.NORTH);
            dialog.add(contentPanel, BorderLayout.CENTER);

            dialog.setModalityType(Dialog.ModalityType.APPLICATION_MODAL); // Set dialog box as modal
            dialog.setVisible(true);

            // Wait until the dialog box is closed
            while (!buttonClicked) {
                try {
                    Thread.sleep(100);
                } catch (InterruptedException ex) {
                    ex.printStackTrace();
                }
            }
        }
}
