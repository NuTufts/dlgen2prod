import os,sys,re
import datetime
import numpy as np
import ROOT as rt
import sample_definitions as sampledefs
from make_booking_file import parse_bookkeeping_file

#samplename = "mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge"
#samplename = "mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge"
#samplename = "mcc9_v29e_dl_run3_G1_extbnb_dlana"
#samplename = "epem_DarkNu_BenchmarkD"
#samplename = "mcc9_v40a_dl_run1_bnb_intrinsic_nue_overlay_CV"
samplename = "mcc9_v29e_dl_run1_C1_extbnb"
#samplename = "mcc9_v28_wctagger_bnboverlay"

reco_version="v3dev_lm_showerkp_retraining"
#reco_version="v2_me_06_03_prodtest"

input_filelist=sampledefs.get_inputfile_list(samplename)
outfolder=sampledefs.gen_standard_reco_outputdir(samplename,reco_version)

# we check the files by
# 1. get the list of input files using the book-keeping file
# 2. we search the reco output directory for files and get their hash. we also check if nentries match the input.
# 3. we get the file ids for input files where there are no reco files and tag them as bad, vice versa good
# 4. we make a file list to run on using the input files marked bad


fbook = parse_bookkeeping_file( samplename, set_is_good_default=False )
print("Number of entries in the bookkeeping file: ",len(fbook))

print()
print()
print("CHECK OUTPUT of ",outfolder)


now = datetime.datetime.now()


# get list of finished reco files
#cmd = "find %s -name larflowreco_*.root -size +1k | sort" % (outfolder)
#cmd = "find %s -name larflowreco_*.root | sort" % (outfolder)
cmd = "find %s -type f -name \"larflowreco_*.root\" -size +1k | grep kpsrecomanagerana | sort" % (outfolder)
print(cmd,flush=True)
plist = os.popen(cmd)
flist = plist.readlines()
print("num lines of larflowreco files: ",len(flist),flush=True)

bad_fileid_list = []
good_fileid_list = []
ngood_events = 0
bad_anafile_list = []
good_anafile_list = []

nchecked = 0
nrecofiles = len(flist)
for f in flist:
  filename = f.replace("\n","")
  #print(filename)
  fbase = os.path.basename(filename)

  if nchecked%100==0 and nchecked>0:
    print("Number checked: ",nchecked," out of ",nrecofiles)

  # get the filehash in order to match to upstream file
  fhash = fbase.split("_")[2]

  if fhash in fbook:
    inputinfo = fbook[fhash]
    #print(inputinfo)
  else:
    print("could not find input info for hash=",fhash,": ",fbase)
    bad_anafile_list.append(filename)
    fbook[fhash]["isgood"] = False
    continue
  
  ninput = inputinfo["nentries"]
  
  try:
    kpsfile = rt.TFile(filename)
    kpst = kpsfile.Get("KPSRecoManagerTree")
    foo = kpst.GetEntries()
    kpsfile.Close()
  except:
    #os.system("rm %s"%filename)
    print("file "+filename+" is bad: could not read the number of entries.")
    bad_fileid_list.append( inputinfo["fileid"] )
    bad_anafile_list.append(filename)
    fbook[fhash]["isgood"] = False
    continue

  if foo!=ninput:
    print(fbase,": input(%d) and output(%d) entries do not match"%(ninput,foo))
    bad_fileid_list.append( inputinfo['fileid'] )
    bad_anafile_list.append(filename)
    fbook[fhash]["isgood"] = False
    continue

  # mark as good
  fbook[fhash]["isgood"] = True
  good_fileid_list.append( inputinfo['fileid'] )
  ngood_events += inputinfo['nentries']
  good_anafile_list.append( filename )
  
  #print("file "+filename+" is good")
print("Bad ID List: ",bad_fileid_list)
print("Good ID List: ",good_fileid_list)
print("Number of good events processed: ",ngood_events)

run_fileid_list = []
for fhash,inputinfo in fbook.items():
  if not inputinfo['isgood'] and inputinfo['nentries']>0:
    run_fileid_list.append( (inputinfo['fileid'],inputinfo['hash']) )    
run_fileid_list.sort()
print("Number of files in run_fileid_list: ",len(run_fileid_list))

# read original input list again
input_files = {}
fin = open(input_filelist,'r')
ff = fin.readlines()
for n,f in enumerate(ff):
  f = f.strip()
  input_files[n] = f
fin.close()

datetag = now.strftime("%Y%m%d_%H%M%S")
runid_filename="runid_list_%s_%s.txt"%(samplename,reco_version)
if os.path.exists(runid_filename):
  runid_filename = runid_filename.replace(".txt","_mod%s.txt"%(datetag))
fout_runid = open(runid_filename,'w')
for (fid,fhash) in run_fileid_list:
  print(fid," ",input_files[fid],file=fout_runid)
fout_runid.close()
print("wrote ",runid_filename)

badoutput_name='badoutput_list_%s_%s.txt'%(samplename,reco_version)
fout_badlist = open(badoutput_name,'w')
for f in bad_anafile_list:
  print(f,file=fout_badlist)
print("wrote bad output file: ",badoutput_name)
  
goodlist_name='goodoutput_lists/goodoutput_list_%s_%s.txt'%(samplename,reco_version)
fout_goodlist = open(goodlist_name,'w')
for f in good_anafile_list:
  print(f,file=fout_goodlist)
print("wrote good list: ",goodlist_name)
  

