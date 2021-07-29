# Gen-2 Reconstruction Scripts

Scripts to run the Gen-2 Reconstruction on a sample of files.

## Workflow

An overview of what you need to do to run files.

1. Compile a list of all the input files in your sample.
2. Make a list of files that need to be run.
3. Modify the submit and run script for the current job.
4. Submit jobs.
5. If not all done, update current run list.
6. Submit jobs again.
7. Repeat steps 5 and 6 until finished.

### (1) Compiling an input file list

The Gen-2 reco stage is downstream of the larmatch step.
This means that the input list can be borrowed from the upstream larmatch script folder.
The input file list will most often be a list of `merged_dlreco` files that come
from the Gen-1 DL Reco-2 stage.

### (2) Make a list of files that need to be run

The reconstruction algorithms require the following inputs:

* `merged_dlreco` file: This is the output of the Gen-1 DL reco 2 stage.
  The files contain the wire images, dead channel databases, and the SSNet output.
* `larmatch`: This contains the output of the larmatch network.
  This primarily includes spacepoints with an associated larmatch score and keypoint network output.

Use `gen_runlist.py` to make the list of files to run.
It works by looking for the larmatch output for each input file from step (1).
If found, it then looks for the Gen-2 reco output files.
If the Gen-2 reco output file is not found, the `merged_dlreco` and `larmatch` file paths
are put into a runlist for use the reconstruction job script.
Before running it, you will need to modify it to indicate for which sample you want to compile a file list.

For example, to specify running the Run 3 EXTBNB data, the following lines are used.

First there are variables to specify the `merged_dlreco` input.
```
samplename = "mcc9_v29e_dl_run3_G1_extbnb_dlana"
inputlist="../maskrcnn_input_filelists/mcc9_v29e_dl_run3_G1_extbnb_dlana_MRCNN_INPUTS_LIST.txt"
stem="merged_dlana"
```

* `samplename` is used to label folders and files.
* `inputlist` is the "master file list" from the previous step.
* `stem` is the beginning of the file name pattern for the merged dlreco file.
  Usually it's `merged_dlreco`, but sometimes it is `merged_dlana`.
  (depending on which Gen-1 processing stage produced the files.)

Next, there are variables to find the output of the larmatch stage.
```
outfolder="/cluster/tufts/wongjiradlab/nutufts/data/v1/%s/larflowreco/larlite/"%(samplename)
larmatch_outfolder="/cluster/tufts/wongjiradlab/nutufts/data/v0/%s/larmatch/"%(samplename)
```

* `larmatch_outfolder`: Unless you change the upstream larmatch output folder, you will not need to change this.
* `outfolder`: This is the folder where the Gen-2 reco script copies output files.
  You probably want to check which version you are using.

When you run it, you'll see a text file that looks something like:

`runlist_reco_mcc9_v29e_dl_run3_G1_extbnb_dlana.txt`

Inside you'll see lines with the following content
```
...
[ID number] [merged_dlreco file] [larmatch file]
...
```

The first column is the job array ID the file pair is assigned to.
The second and third columns are the input files the reconstruction needs.

The goal is to repeatedly submit jobs and then update this list.
Eventually, if all goes well, the output of `gen_runlist.py` will be empty.


### (3) Modify the submit and run script for the current job







