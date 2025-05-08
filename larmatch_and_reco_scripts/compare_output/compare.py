import os,sys
import ROOT as rt

# the original "v3"
v3devfile="../reserve_v3dev_copy/mcc9_v29e_dl_run1_C1_extbnb/larflowreco_fileid1060_90e3e1cb-a5d2-4d02-b7a2-e824699c417f_kpsrecomanagerana.root"

# the version after the prodmerge
#prodmergefile="../reserve_prodmerge_copy/"
prodmergefile="larflowreco_fileid1060_90e3e1cb-a5d2-4d02-b7a2-e824699c417f_kpsrecomanagerana.root"

files = {'v3dev':v3devfile,
         'prodmerge':prodmergefile}

filetypes=["v3dev","prodmerge"]

rfile = {}
tree = {}


for ftype in filetypes:
    rfile[ftype] = rt.TFile(files[ftype],'read')
    tree[ftype] = rfile[ftype].Get("KPSRecoManagerTree")

nentries = tree['v3dev'].GetEntries()
if nentries>tree['prodmerge'].GetEntries():
    nentries = tree['prodmerge'].GetEntries()
    
print("Number of entries in 'v3dev': ",nentries)

metrics = ['nvertices','kptype','kpscores','ntracks','nshowers','track_nhits','track_kemu','shower_nhits','shower_pixsum']

for ientry in range(nentries):

    print("=====================================")
    print("ENTRY[",ientry,"]")
    
    # gather data
    data_v = {}
    for ftype in filetypes:
        data = {}
        tree[ftype].GetEntry(ientry)
        kpst = tree[ftype]
        data['nvertices'] = kpst.nuvetoed_v.size()

        # vertex level data
        kpscores = []
        ntracks = []
        nshowers = []
        kptype = []
        track_nhits = []
        track_kemu = []
        shower_nhits = []
        shower_pixsum = []
        for ivtx in range(data['nvertices']):
            vtx = kpst.nuvetoed_v.at(ivtx)
            kpscores.append( vtx.score )
            ntracks.append( vtx.track_v.size() )
            nshowers.append( vtx.shower_v.size() )
            kptype.append( vtx.keypoint_type )
            for itrack in range( vtx.track_v.size() ):
                track_nhits.append( vtx.track_hitcluster_v.at(itrack).size() )
                track_kemu.append( vtx.track_kemu_v.at(itrack) )
            for ishower in range(vtx.shower_v.size()):
                shower_nhits.append( vtx.shower_v.at(ishower).size() )
                pixsum = 0.0
                for p in range(3):
                    pixsum += vtx.shower_plane_pixsum_vv.at(ishower).at(p)
                shower_pixsum.append(pixsum)
                                     

        data['kpscores'] = kpscores
        data['ntracks'] = ntracks
        data['nshowers'] = nshowers
        data['kptype'] = kptype
        data['track_nhits'] = track_nhits
        data['track_kemu'] = track_kemu
        data['shower_nhits'] = shower_nhits
        data['shower_pixsum'] = shower_pixsum

        data_v[ftype] = data

    for metric in metrics:
        print(metric,": v3dev=",data_v['v3dev'][metric],"  prodmerge=",data_v['prodmerge'][metric])

    if ientry>=5:
        break
            
        

    
