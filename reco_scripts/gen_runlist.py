from __future__ import print_function
import os,sys,re


#samplename = "mcc9_v29e_dl_run3b_intrinsic_nue_LowE"
#inputlist="../maskrcnn_input_filelists/mcc9_v29e_dl_run3b_bnb_intrinsic_nue_LowE_MRCNN_INPUTS_LIST.txt"
#stem="merged_dlreco"

samplename = "mcc9_v29e_dl_run3_G1_extbnb_dlana"
inputlist="../maskrcnn_input_filelists/mcc9_v29e_dl_run3_G1_extbnb_dlana_MRCNN_INPUTS_LIST.txt"
stem="merged_dlana"

#samplename = "mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge"
#inputlist="inputlists/mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge.list"
#stem="merged_dlreco"

outfolder="/cluster/tufts/wongjiradlab/nutufts/data/v0/%s/larflowreco/larlite/"%(samplename)
larmatch_outfolder="/cluster/tufts/wongjiradlab/nutufts/data/v0/%s/larmatch/"%(samplename)

# get list of finished vareco files
cmd = "find %s -name larflowreco_*.root -size +1k | sort" % (outfolder)
print(cmd)
plist = os.popen(cmd)
flist = plist.readlines()

finished = []

for f in flist:
    f = f.strip()
    #print(f)
    base = os.path.basename(f)
    #print(base.split("fileid")[-1])
    x = re.split("[_-]+",base.split("fileid")[-1])
    #print(x)
    try:
        jobid = int(x[0])        
    except:        
        print("error parsing file: ",f," :: ",x)
        sys.exit(-1)
    finished.append(jobid)
    #print(jobid," ",base)    

finished.sort()
print("Number of finished files: ",len(finished))
#input()

# need list of larmatch files
cmd = "find %s -name larmatch_kps*larlite.root -size +100k | sort"%(larmatch_outfolder)
print(cmd)
plist = os.popen(cmd)
flist = plist.readlines()
lm_finished = {}
for f in flist:
    f = f.strip()
    print(f)
    f1 = f.replace("_larlite.root","")

    if samplename in ["mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge",
                      "mcc9_v29e_dl_run3_G1_extbnb_dlana"]:
        h = f1.split("larmatch_kps_fileid")[-1].split("_")[-1]
    elif samplename in ["mcc9_v29e_dl_run3b_intrinsic_nue_LowE"]:
        h = f.split("larmatch_kps_")[-1].split("-jobid")[0]
        
    print(h)
    lm_finished[h] = f

print("larmatch files finished: ",len(lm_finished))
#input()

pnjobs = os.popen("cat %s | wc -l"%(inputlist))
njobs = int(pnjobs.readlines()[0])

print("Number of files in input list: ",njobs)
missing = []
for i in range(njobs):
    if i not in finished:
        missing.append(i)
missing.sort()        
print("Number of missing files: ",len(missing))

foutname="runlist_reco_%s.txt"%(samplename)
print("Making file, %s, with file IDs to run"%(foutname))
fout = open(foutname,'w')
for fileid in missing:
    # get dlmerged input
    pout = os.popen( "sed -n %dp %s"%(fileid+1,inputlist))
    dlmerged = pout.readlines()[0].strip()
    h = dlmerged.split(stem+"_")[-1].split(".root")[0]
    #base = os.path.basename( dlmerged ).split(
    #h = re.split("[_-]+",base.split("fileid")[-1])    
    print(h)
    if h in lm_finished:
        lmfile = lm_finished[h]
        print("%d %s %s"%(fileid,dlmerged,lmfile),file=fout)
    else:
        print("No larmatch file for %s"%(os.path.basename(dlmerged)))
fout.close()


