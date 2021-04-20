import os,sys
import ROOT as rt
import numpy as np

weight_dir="/cluster/tufts/wongjiradlab/nutufts/data/weights/forCV_v48_Sep24/"
#weight_file="weights_forCV_v48_Sep24_intrinsic_nue_run1.root"
weight_file="weights_forCV_v48_Sep24_intrinsic_nue_run3.root"
input_file="/cluster/tufts/wongjiradlab/nutufts/data/v1/mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge/larflowreco/ana/000/larflowreco_fileid0000_001361e0-3306-491f-9098-1d08eee8458b_kpsrecomanagerana.root"
out_filename = "test.root"

print("WEIGHT DIR: ",weight_dir)
print("WEIGHT FILE: ",weight_file)
print("INPUT FILE: ",os.path.basename(input_file))
print("WEIGHT PATH: ",weight_dir+'/'+weight_file)

df = rt.RDataFrame( "eventweight_tree", weight_dir+"/"+weight_file )
tf = rt.TFile(input_file)
kpsana = tf.Get("KPSRecoManagerTree")
nentries = kpsana.GetEntries()
print("NUM ENTRIES: ",nentries)

columns=["run","subrun","event","xsec_corr_weight","lee_weight","nu_energy_true"]
out_dict = {}
for col in columns:
    if col in ["run","subrun","event"]:
        out_dict[col] = np.zeros(nentries,dtype=np.int)
    else:
        out_dict[col] = np.zeros(nentries,dtype=np.float)
        
for ientry in range(nentries):
    kpsana.GetEntry(ientry)
    run = kpsana.run
    subrun = kpsana.subrun
    event  = kpsana.event

    match = df.Filter("run==%d"%(run))\
              .Filter("subrun==%d"%(subrun))\
              .Filter("event==%d"%(event))\
              .AsNumpy(columns=["run","subrun","event","xsec_corr_weight","lee_weight","nu_energy_true"])

    print((run,subrun,event),": ",match)
    for col in columns:
        #print(col, ": ", type(match[col]), match[col].shape," ",out_dict[col].shape)
        #print("  ",match[col][0])
        out_dict[col][ientry] = match[col][0]

print("Filled output tree")
#print(out_dict)

outdf = rt.RDF.MakeNumpyDataFrame(out_dict)
outdf.Snapshot("eventweight",out_filename)
