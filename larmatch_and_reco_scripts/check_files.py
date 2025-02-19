
import os,sys,re
import numpy as np
import ROOT as rt
import sample_definitions as sampledefs

#samplename = "mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge"
#samplename = "mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge"
#samplename = "mcc9_v29e_dl_run3_G1_extbnb_dlana"
#samplename = "epem_DarkNu_BenchmarkD"

reco_version="v3dev_lm_showerkp_retraining"
samplename = "mcc9_v28_wctagger_bnb5e19"
input_filelist=sampledefs.get_inputfile_list(samplename)
outfolder=sampledefs.get_reco_output_dir(samplename)
outfolder=sampledegs.get_standard_reco_outputdir(samplename,reco_version)

FORCE_BOOK_MAKING=False # Set this flag to force the bookkeeping file to be re-made. Try not to do this.
bookkeeping_info_file=sampledefs.get_sample_info['bookkeeping']

if not os.path.exists(bookkeeping_info_file):
  MAKE_BOOK=True # make the book-keeping file if not found.
else:  
  if FORCE_BOOK_MAKING:
    print("Re-making bookkeeping file: ",bookkeeping_info_file)
    print("You sure?")
    print("[enter 'Y' to continue anything else to stop")
    choice = input()
    if choice!="Y":
      print("Stopping")
      sys.exit(0)
    else:
      MAKE_BOOK=True
  else:
    MAKE_BOOK=False


if MAKE_BOOK:
  f = open(input_filelist,'r')
  ll = f.readlines()
  bookout = open(bookkeeping_info_file,'w')
  for n,l in enumerate(ll):
    l = l.strip()
    lb = os.path.basename(l)
    # open root file, get number of entries, run/subrun/event list
    r = rt.TFile( l, 'open' )
    imagetree = r.Get("image2d_wire_tree")
    idtree = r.Get("larlite_id_tree")
    nentries = imagetree.GetEntries()
    print("---------------------------------------")
    print(l,": ",nentries)
    runid    = np.zeros(nentries,dtype=np.int64)
    subrunid = np.zeros(nentries,dtype=np.int64)
    eventid  = np.zeros(nentries,dtype=np.int64)
    isok = True
    for i in range(nentries):
      try:
        idtree.GetEntry(i)
      except:
        isok = False
        break
      #print(" [",i,"] (",(idtree._run_id,idtree._subrun_id,idtree._event_id))
      runid[i] = idtree._run_id
      subrunid[i] = idtree._subrun_id
      eventid[i] = idtree._event_id
    r.Close()
    if isok:
      print(n," ",nentries," ",runid.min()," ",runid.max()," ",subrunid.min(),"",subrunid.max()," ",eventid.min()," ",eventid.max()," ",lb,file=bookout)
  bookout.close()


print()
print()
print("CHECK OUTPUT of ",outfolder)
fbook = open(bookkeeping_info_file,'r')
ll = fbook.readlines()
fileinfo = {}
fileid_list = []
for l in ll:
  l = l.strip().split()
  fileid = int(l[0])
  fname = l[-1]
  nentries = int(l[1])
  if samplename in ["mcc9_v40a_dl_run3b_bnb_nu_overlay_500k_CV","mcc9_v28_wctagger_bnb5e19"]:
    fhash = fname.split("merged_dlreco_")[-1].split(".root")[0]
  elif samplename in ["mcc9_v29e_dl_run3_G1_extbnb_dlana"]:
    fhash = fname.split("merged_dlana_")[-1].split(".root")[0]
  else:
    print("sample name not in known list")
    sys.exit(0)
    
  fileinfo[fhash] = {"fileid":fileid,"name":fname,"nentries":nentries,"hash":fhash,"isgood":False}
  fileid_list.append(fileid)
print("number of files: ",len(fileinfo))
fileid_list.sort()
    
# get list of finished reco files
#cmd = "find %s -name larflowreco_*.root -size +1k | sort" % (outfolder)
#cmd = "find %s -name larflowreco_*.root | sort" % (outfolder)
cmd = "find %s -type f -name \"larflowreco_*.root\" -size +1k | grep kpsrecomanagerana | sort" % (outfolder)
print(cmd)
plist = os.popen(cmd)
flist = plist.readlines()
print("num lines: ",len(flist))

bad_fileid_list = []
good_fileid_list = []
ngood_events = 0
bad_anafile_list = []
good_anafile_list = []

for f in flist:
  filename = f.replace("\n","")
  #print(filename)
  fbase = os.path.basename(filename)
  fhash = fbase.split("_")[2]

  if fhash in fileinfo:
    inputinfo = fileinfo[fhash]
    #print(inputinfo)
  else:
    print("could not find input info for hash=",fhash,": ",fbase)
    bad_anafile_list.append(filename)
    continue
  
  ninput = inputinfo["nentries"]
  
  try:
    kpsfile = rt.TFile(filename)
    kpst = kpsfile.Get("KPSRecoManagerTree")
    foo = kpst.GetEntries()
    kpsfile.Close()
  except:
    #os.system("rm %s"%filename)
    print("file "+filename+" is bad")
    bad_fileid_list.append( inputinfo["fileid"] )
    bad_anafile_list.append(filename)    
    continue

  if foo!=ninput:
    print(fbase,": input(%d) and output(%d) entries do not match"%(ninput,foo))
    bad_fileid_list.append( inputinfo['fileid'] )
    bad_anafile_list.append(filename)    
    continue

  # mark as good
  inputinfo["isgood"] = True
  good_fileid_list.append( inputinfo['fileid'] )
  ngood_events += inputinfo['nentries']
  good_anafile_list.append( filename )
  
  #print("file "+filename+" is good")
print("Bad ID List: ",bad_fileid_list)
print("Good ID List: ",good_fileid_list)
print("Number of good events processed: ",ngood_events)

run_fileid_list = []
for fhash,inputinfo in fileinfo.items():
  if not inputinfo['isgood']:
    run_fileid_list.append( (inputinfo['fileid'],inputinfo['hash']) )
run_fileid_list.sort()

# read original input list again
input_files = {}
fin = open(input_filelist,'r')
ff = fin.readlines()
for n,f in enumerate(ff):
  f = f.strip()
  input_files[n] = f
fin.close()

fout_runid = open("runid_list_%s.txt"%(samplename),'w')
for (fid,fhash) in run_fileid_list:
  print(fid," ",input_files[fid],file=fout_runid)
fout_runid.close()

fout_badlist = open('badoutput_list_%s.txt'%(samplename),'w')
for f in bad_anafile_list:
  print(f,file=fout_badlist)

fout_goodlist = open('goodoutput_lists/goodoutput_list_%s.txt'%(samplename),'w')
for f in good_anafile_list:
  print(f,file=fout_goodlist)
  

