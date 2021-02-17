from __future__ import print_function
import os,sys,re


#samplename = "mcc9jan_run1_bnb5e19"
#inputlist="../run1inputlists/mcc9jan_run1_bnb5e19.list"

#samplename="mcc9_v29e_dl_run3_G1_extbnb_dlana"
#inputlist="../maskrcnn_input_filelists/mcc9_v29e_dl_run3_G1_extbnb_dlana_MRCNN_INPUTS_LIST.txt"

#samplename = "mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge"
#inputlist="../run3inputlists/mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge.list"

samplename = "mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge"
inputlist="../maskrcnn_input_filelists/mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge_MRCNN_INPUTS_LIST.txt"

outfolder="../../data/v0/%s/larmatch/"%(samplename)

# get list of finished files
cmd = "find %s -name larmatch_kps_*.root -size +2000k | sort" % (outfolder)
print(cmd)
plist = os.popen(cmd)
flist = plist.readlines()

finished = []

for f in flist:
    f = f.strip()
    #print(f)
    base = os.path.basename(f)
    #print(base.split("fileid")[-1])
    if samplename in ["mcc9jan_run1_bnb5e19",
                      "mcc9_v29e_dl_run3_G1_extbnb_dlana",
                      "mcc9_v29e_dl_run3b_bnb_nu_overlay_nocrtremerge",
                      "mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge"]:
        x = re.split("[_-]+",base.split("fileid")[-1])
    else:
        raise ValueError("not yet implemented")

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

pnjobs = os.popen("cat %s | wc -l"%(inputlist))
njobs = int(pnjobs.readlines()[0])

print("Number of files in input list: ",njobs)
missing = []
for i in range(njobs):
    if i not in finished:
        missing.append(i)
missing.sort()        
print("Number of missing files: ",len(missing))

foutname="larmatch_runlist_%s.txt"%(samplename)
print("Making file, %s, with file IDs to run"%(foutname))
fout = open(foutname,'w')
for fileid in missing:
    print("%d"%(fileid),file=fout)
fout.close()


