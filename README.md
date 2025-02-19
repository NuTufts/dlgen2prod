# dlgen2prod

Production Scripts and Book Keeping for the LANTERN Reconstruction (aka DL-Gen2).

TL;DR: The `larmatch_and_reco_scripts` folder contains scripts for making LANTERN reco files.
Then use the [gen2ntuple](https://github.com/NuTufts/gen2ntuple) repository to make the ntuples for analysis.

Current analysis repositories. These use the ntuple files made by `gen2ntuple`.

* Single photon analysis: [ubphoton](https://github.com/NuTufts/ubphoton)
* Inclusive CC numu and nue analysis: [gen2val](https://github.com/mmrosenberg/gen2val)

# Inputs

We work from "dlmerged files", which are files dervied from the MicroBooNE simulation and data larsoft files.
The data in the larsoft files are stored as serialized C++ classes defined in the various larsoft libaries.
We convert them into our own set of classes defined in the more portable `larlite` and `larcv` libraries.

The key data products in these dlmerged files are:

1. The wire plane images (stored as `larcv::Image2D` instances)
2. Flags for good and bad wires (also stored as `larcv::Image2D` instances)
3. Optical information: the amount of light seen in a PMT during a scintillation light pulse (`larlite::opreco` instances)
4. Tagged pixels related to energy depositions made by particles out-of-time with the beam (stored in `larcv::Image2D` instances)
5. Track+Shower labels for 2D pixels made by the Sparse UResNet network (saved as `larcv::Image2D`)

For simulated data, we store metadata critical in analysis:

1. Particle trajectories through the TPC
2. List of particles produced and tracked in the simulation
3. Information about the neutrino interaction
4. Information about the location of ionization in the TPC. This is fundamentally 3D information compressed into 2D images.
5. Pixel labels about the particles responsible for the deposited ionization in the wireplane images.

# Workflow

From the dlmerged files, we pass the files through a series of steps

* Sparse UResNet (if we are working with images that does not have this info. yet)
* LArMatch: produces reconstructed 3D spacepoints with various labels along with keypoints
* LArFlow Reco: analyzes the 3D points and attempts to reconstruct neutrino interactions and, to some degree, background cosmic muons
* gen2ntuple: For neutrino candidates, runs the LArPID CNN on the particle prongs and makes the ntuple files for analysis

For space reasons, we typically only store information on the reconstructed neutrino candidates (kpsreco files) and
the ntuples.
LArMatch output and the full reco outputs are intermediate files which are deleted during the processing.

# Data Samples on Tufts

Here we document the files on Tufts.

Also see this repository ([tufts_storage_info](https://github.com/NuTufts/tufts_storage_info)) for more of a detailed accounting on storage usage.

For our purposes, the input files are divided into different type of samples and are mainly different types of simulated data.
(Real data processing must be done at Fermilab.)

The input files for each sample are stored in a text file. These text files are used to define what files need to made.
All input files have a unique hash tag that is used to label the output files of the different stages of processing.
This is how we track which files have been processed and from what files they have been derived.

However, some such files are made available for analysis purposes.

Example:

```
merged_dlreco_3ab3a878-3aea-4bc7-926e-bbb7554875f1.root
```

will make files with names like:

```
larmatch_3ab3a878-3aea-4bc7-926e-bbb7554875f1_larlite.root
larmatch_3ab3a878-3aea-4bc7-926e-bbb7554875f1_larcv.root
```

## Location of Output files

The place to store LANTERN output files are here:

`/cluster/tufts/wongjiradlabnu/nutufts/data`

The two main folders right now are:

* `v2_me_06`: this is the "production" version of LANTERN output. It was used to demonstrate an increased efficiency (+30%) for an inclusive CC electron neutrino selection by M. Rosenberg.
* `v3dev_lm_showerkp_retraining`: these are files being used to develop the improved shower reconstruction and single photon selection analysis.

## Run 1 Files

## Run 2 Files

## RUN 3 Files

Input Data sets. File lists stored in `run3inputlists`.

| Sample Type    | Num files | Official File List(s) |
| -----------    | --------- | --------------------- |
| BNB Nu         | 15519     | run3inputlists/mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge.list |
| BNB intrinsics | 2232      | maskrcnn_input_filelists/mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge_MRCNN_INPUTS_LIST.txt |
| BNB LowE       | 580       | mcc9_v29e_dl_run3b_bnb_intrinsic_nue_LowE_forlarmatch.list  |
| EXTBNB         | 17697     | mcc9_v29e_dl_run3_G1_extbnb_dlana_MRCNN_INPUTS_LIST.txt |
| RUN 1 5e19     | 13745     | run1inputlists/mcc9jan_run1_bnb5e19.list |

LArMatch Lists. How do we know how to align files? In folder, `larmatchlists`.

Current version: v0.

Files need to be verified. (some have been destroyed for space)

| Sample Type    | Num files | Official File List(s) | Size |
| -----------    | --------- | --------------------- | ---- |
| BNB Nu         | 15519     | larmatch_mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge.list | 2.4 TB  |
| BNB intrinsics | 2232 | larmatch_mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge.list | 323 GB |
| BNB LowE       | 580 | larmatch_v0_mcc9_v29e_dl_run3b_intrinsic_nue_LowE.list | 110 GB |
| EXTBNB         | 17697 | larmatch_v0_mcc9_v29e_dl_run3_G1_extbnb_dlana.list | 869 GB |
| RUN 1 5e19     | 13745 | larmatch_v0_mcc9jan_run1_bnb5e19.list | 698 GB |

Mask-RCNN files

| Sample Type | Num Files | Official File List(s) |
| ----------- | --------- | ----------- |
| BNB Nu      |   x       | x            |
| BNB intrinsics | x | x |
| BNB LowE | x | x |
| EXTBNB | x | x |
| RUN 1 5e19 | x | x |

LArFlow Reco Lists. How do we know how to align files? In folder, `lfrecolists`.

| Sample Type    | Num files | Official File List(s) |
| -----------    | --------- | ----------- |
| BNB Nu         |   x       | x           |
| BNB intrinsics | x | x |
| BNB LowE       | x | x | 
| EXTBNB         | x | x |
| RUN 1 5e19     | x | x |

Weight files. These are the CV weights.

Systematic Uncertainty Variation weights. (Do we have access to these at tufts?)
