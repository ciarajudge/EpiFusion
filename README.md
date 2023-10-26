# EpiFusion
This is EpiFusion, a program for jointly inferring epidemic trajectories using phylogenetic and case incidence data via particle filtering. This repository contains the model source code, and other useful examples and templates.


## Getting Started

To get started with EpiFusion you can get started by downloading this executable jar file. To run the program, simply ensure that you have Java 8 installed, and run the following command: 

  ```sh
  java -jar EpiFusion parameterfile.xml
  ```

We recommend using a parameter file from the examples folder for your first attempt at running EpiFusion. These examples should take about 30 minutes to run, and their outputs will be found in your working directory. The output can be plotted and interpreted using the markdown script plot_epifusion_outputs.Rmd in the examples folder. For information on creating your own parameter XML files for EpiFusion, see the 'Parameter XML' section of the wiki.


## Contributing, Collaborating and Feedback

We encourage any user to point out problems or suggest ideas for improvement by raising an issue, and we will address these (particularly bugs) as quickly as possible. Pull requests are also welcome, but please allow grace in the time we take to review. For an insight into our planned improvements, to the program, check some of the open issues left by the development team.


## License

We are sharing EpiFusion as a free software under the GNU General Public License (v3). We point out that the models implemented by EpiFusion are awaiting peer review, and the program is in it's infancy. We recommend caution in its use and ask for patience as continue to validate it.


## Acknowledgements
Thank you to all the individuals and organisations that have a role in EpiFusion's creation and maintenance. These include the London School of Hygiene and Tropical Medicine, the Royal Veterinary College, and ETH Zurich. Key contributors include Ciara Judge, Tim Vaughan, Tim Russell, Sam Abbott, Louis Du Plessis, Tanja Stadler, Oliver Brady, and Sarah Hill.




