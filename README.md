# *Caenorhabditis elegans* Multi-Tracker Based on a Modified Skeleton Algorithm (WT-ISA) [DOI](https://doi.org/10.3390/s21165622)
![GitHub Logo](https://github.com/playanaC/WT_ISA/blob/main/pipeline2_WT_ISA.png)

In this work, a new worm tracker is proposed using the improved skeletonization algorithm ( WT_ISA ), proposed in a previous work, [ISA](https://doi.org/10.1038/s41598-020-79430-8). Using this new skeleton some possible predictions of the next pose are obtained. An optimization function with different parameters evaluates all predictions and selects the optimal skeleton. The parameters evaluated were: Overlap, completeness, noise, color, length, smoothness. With each of these parameters, different prediction models were designed. The model with the best results obtained an accuracy of 99.42% in aggregated worm tracks and an IoU value of 0.69 during aggregations. This model used the parameters of overlap, completeness, noise and color.

# Requirements:
This demo was tested in Windows 10 with Matlab R2018b.
- Windows 10
- Matlab R2018b
- Image Processing Toolbox
- Communications Toolbox
- Bioinformatics Toolbox

# Clone Skeletonization repository:
```
git clone https://github.com/playanaC/WT_ISA.git
```
# Dataset:
- The dataset with all aggregation experiments can be downloaded from [dataset_skeletons](https://active-vision.ai2.upv.es/wp-content/uploads/2021/02/dataset_skeletons.zip).

# Run the skeletonization demo in Matlab:
- Before you start, change the path of the images in *pathl1 variable* in Main.m file.
- The different parameters are found on lines 94 - 118 and 178 - 221 of *predict_skeletons.m* file. If you want to work with any of them, it is necessary to comment or     uncomment as necessary.
- Run Main.m macro. This macro will first find the region of interest (inside the petri dish), then it will get all the worm trajectories, these will be evaluated to classify the areas in worm tracks(red), noise (blue), areas with little movement (green). Second, you will evaluate each tracks to obtain all the worm skeletons within it. Third, the results will be saved in xml files. 
- The name of each model is a number, and can be changed in line 85 of the *Main.m file*. The xml files where the results of the skeletons are saved will have the name of the model accompanied by *_M_DT#*. We use *M* for the models that skeletonization is used [ISA](https://doi.org/10.1038/s41598-020-79430-8) and *N* for classical skeletonization. The value of *#* is the number of the worm track.

# Run Gui_viewer in Matlab:
Gui_viewer is an app to view the results saved in xmls files.
- First you must select the path of the images with the xmls files using *Path* button.
- Second in *button group* at the bottom you must select one of the options.
- Third, if *Single worm* was selected, one of the xml files must be selected, and then one of the images should be selected to see the skeleton in image 1 and in image 2 with increased resolution.
- If *All worms* was selected, only one of the images should be selected to see all the worm skeletons. At the top, you can select *Zoom in* to get a closer look at each skeleton in image 1.

# Image adquisition system:
- Images were captured by an [open hardware system](https://github.com/JCPuchalt/c-elegans_smartLight).


# References:
- Layana Castro Pablo E., Puchalt, J.C., Sánchez-Salmerón, A. "Improving skeleton algorithm for helping *Caenorhabditis elegans* trackers". Scientific Reports (2020) [doi paper](https://doi.org/10.1038/s41598-020-79430-8).

- Puchalt, J. C., Sánchez-Salmerón, A.-J., Martorell Guerola, P. & Genovés Martínez, S. "Active backlight for automating visual monitoring: An analysis of a lighting control technique for *Caenorhabditis elegans* cultured on standard Petri plates". PLOS ONE 14.4 (2019) [doi paper](https://doi.org/10.1371/journal.pone.0215548)

- Puchalt, J.C., Sánchez-Salmerón, A., Ivorra, E. et al. "Improving lifespan automation for *Caenorhabditis elegans* by using image processing and a post-processing adaptive data filter". Scientific Reports (2020) [doi paper](https://doi.org/10.1038/s41598-020-65619-4).
