# LArMatch and Reco Combined Jobs

Takes in dlmerged files and runs larmatch and then the larmatch reco.

The larmatch output that goes into the reconstruction is deleted during the job.

## Workflow

1. To process a sample, first make or get an inputlist of dlmerged files.
2. Go into `sample_definitions.py` and add info about your sample into the sample_definitions dictionary.
3. Run `check_files.py`. This will make a book-keeping file that will assign a file ID to each input file along with information about the files.
   It will also make a `runid_list_[samplename].txt` file that the job scripts will use to determine which files still need to be processed.
   It also checks for output files and does a simple test to see if they are OK.
   Good files are listed in `goodoutput_lsits/goodoutput_list_[samplename].txt`.
   This list can be used for downstream work, such as `gen2ntuple`.
4. Make a batch submission file. See others for templates.
5. Launch jobs using the batch submission script. After jobs are done, run `check_files.py` to update `runid_list` file.
6. Repeat Step 5 until files are successfully processed. Note: it is known that some files will not complete.
   Important to do is to understand what happen to these files.


Note that the submission scripts provides commands to worker nodes to run a "job script".
These are the following standard scripts that are called:

1. `run_batch_larmatchme_and_reco_mc.sh`
2. `run_batch_larmatchme_and_reco_data.sh`

Script (1) is for simulated data; (2) is for real data. Real data includes neutrino beam data and EXT-BNB data where there is no simulated truth stored.
The MC script version includes commands to tell the various processes to use and pass-on simulated meta-data.